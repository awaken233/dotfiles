-- Spring Boot API 端点搜索工具
local M = {}

local telescope = require("telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local utils = require("telescope.utils")

-- Spring Boot 端点映射注解模式（只搜索方法级别的端点映射）
local SPRING_ANNOTATIONS = {
  "@GetMapping", 
  "@PostMapping",
  "@PutMapping",
  "@DeleteMapping",
  "@PatchMapping",
}

-- 构建 ripgrep 搜索命令
local function build_rg_command()
  local pattern = table.concat(SPRING_ANNOTATIONS, "|")
  return {
    "rg",
    "--type", "java",
    "--line-number",
    "--column",
    "--no-heading",
    "--color=never",
    "--smart-case",
    "-e", pattern,
    ".",
  }
end

-- 解析 ripgrep 输出行
local function parse_rg_line(line)
  local file, lnum, col, text = line:match("^([^:]+):(%d+):(%d+):(.*)$")
  if not file then
    return nil
  end
  
  return {
    filename = file,
    lnum = tonumber(lnum),
    col = tonumber(col),
    text = vim.trim(text),
  }
end

-- 查找文件中的主要类定义（更可靠的方法）
local function find_main_class(lines)
  -- 在整个文件中查找第一个 public class（通常是主要类）
  for i = 1, #lines do
    local line = lines[i] or ""
    if line:match("public%s+class%s+%w+") then
      local class_name = line:match("public%s+class%s+(%w+)")
      return i, class_name
    end
  end
  return nil, ""
end

-- 在类定义附近查找 @RequestMapping
local function find_request_mapping_before_class(lines, class_line, search_range)
  local start_line = math.max(1, class_line - search_range)
  
  for i = start_line, class_line do
    local line = lines[i] or ""
    if line:match("@RequestMapping") then
      local mapping = line:match('@RequestMapping%s*%(%s*"([^"]*)"') or
                     line:match('@RequestMapping%s*%(%s*value%s*=%s*"([^"]*)"') or
                     line:match('@RequestMapping%s*%(%s*path%s*=%s*"([^"]*)"')
      if mapping then
        return mapping
      end
    end
  end
  return ""
end

-- 提取类和方法的路径信息
local function extract_endpoint_info(file_path, line_num)
  local lines = vim.fn.readfile(file_path)
  if not lines then return nil end
  
  local method_mapping = ""
  local method_name = ""
  local method_type = ""
  local mapping_annotation_line = line_num  -- 默认为原始行号
  
  -- 使用最优方案：查找文件中的主要类定义和对应的 @RequestMapping
  local class_line, class_name = find_main_class(lines)
  local class_mapping = ""
  
  if class_line then
    class_mapping = find_request_mapping_before_class(lines, class_line, 5)
  end
  
  -- 查找方法级别的映射注解（从当前行开始，向下查找10行）
  local found_method_mapping = false
  mapping_annotation_line = line_num  -- 默认就是当前行
  
  -- 从当前行开始查找方法级别的映射注解
  for i = line_num, math.min(#lines, line_num + 10) do
    local line = lines[i] or ""
    
    if line:match("@%w*Mapping") and not line:match("@RequestMapping") then
      method_type = line:match("@(%w*)Mapping") or ""
      local mapping = line:match('@%w*Mapping%s*%(%s*"([^"]*)"') or
                     line:match('@%w*Mapping%s*%(%s*value%s*=%s*"([^"]*)"') or
                     line:match('@%w*Mapping%s*%(%s*path%s*=%s*"([^"]*)"')
      if mapping then
        method_mapping = mapping
        mapping_annotation_line = i  -- 记录映射注解的实际行号
        found_method_mapping = true
        break
      end
    end
  end
  
  -- 查找方法名
  for i = mapping_annotation_line, math.min(#lines, mapping_annotation_line + 10) do
    local line = lines[i] or ""
    
    -- 如果找到方法定义，提取方法名并停止搜索
    if line:match("public.*%w+%s*%(") or line:match("private.*%w+%s*%(") then
      method_name = line:match("%w+%s+(%w+)%s*%(") or line:match("(%w+)%s*%(")
      break
    end
  end
  
  -- 构建完整路径
  local full_path = ""
  
  -- 处理类级别路径
  if class_mapping ~= "" then
    -- 确保类级别路径以 / 开头
    if not class_mapping:match("^/") then
      full_path = "/" .. class_mapping
    else
      full_path = class_mapping
    end
  end
  
  -- 处理方法级别路径
  if method_mapping ~= "" then
    if full_path ~= "" then
      -- 如果方法路径不以 / 开头，添加 /
      if not method_mapping:match("^/") then
        full_path = full_path .. "/" .. method_mapping
      else
        full_path = full_path .. method_mapping
      end
    else
      -- 如果没有类级别路径，确保方法路径以 / 开头
      if not method_mapping:match("^/") then
        full_path = "/" .. method_mapping
      else
        full_path = method_mapping
      end
    end
  end
  
  -- 清理路径，移除多余的斜杠
  full_path = full_path:gsub("//+", "/")

  return {
    path = full_path,
    class_name = class_name,
    method_name = method_name,
    method_type = method_type,
    class_mapping = class_mapping,
    method_mapping = method_mapping,
    actual_line = mapping_annotation_line,  -- 实际的映射注解行号
  }
end

-- 格式化显示条目
local function format_entry(entry)
  local info = entry.endpoint_info
  if not info or info.path == "" then
    return entry.text
  end
  
  -- 获取 HTTP 方法
  local http_method = "UNKNOWN"
  if info.method_type then
    local method_map = {
      Get = "GET",
      Post = "POST", 
      Put = "PUT",
      Delete = "DELETE",
      Patch = "PATCH",
      Request = "ALL"
    }
    http_method = method_map[info.method_type] or "ALL"
  end
  
  -- 简化显示：只显示HTTP方法和路径
  return string.format("%-6s %s", http_method, info.path)
end

-- 创建自定义预览器
local function create_previewer()
  return previewers.new_buffer_previewer({
    title = "API 端点代码预览",
    get_buffer_by_name = function(_, entry)
      return entry.filename
    end,
    define_preview = function(self, entry, status)
      conf.buffer_previewer_maker(entry.filename, self.state.bufnr, {
        bufname = self.state.bufname,
        winid = self.state.winid,
        preview = {
          msg = entry.filename,
        },
        callback = function(bufnr)
          -- 清除所有之前的高亮
          vim.api.nvim_buf_clear_namespace(bufnr, -1, 0, -1)
          
          -- 高亮当前端点行（使用显眼的高亮）
          vim.api.nvim_buf_add_highlight(bufnr, -1, "CursorLine", entry.lnum - 1, 0, -1)
          
          -- 将光标定位到目标行
          pcall(vim.api.nvim_win_set_cursor, status.preview_win, { entry.lnum, 0 })
          
          -- 确保目标行在视窗中可见
          vim.defer_fn(function()
            if vim.api.nvim_win_is_valid(status.preview_win) then
              vim.api.nvim_win_call(status.preview_win, function()
                vim.cmd("normal! zz")  -- 居中显示当前行
              end)
            end
          end, 50)
        end,
      })
    end,
  })
end

-- 主搜索函数
function M.search_spring_endpoints()
  -- 检查是否在 Java 项目中
  local cwd = vim.fn.getcwd()
  if vim.fn.isdirectory(cwd .. "/src") == 0 and vim.fn.filereadable(cwd .. "/pom.xml") == 0 then
    vim.notify("当前目录似乎不是 Java 项目", vim.log.levels.WARN)
  end
  
  local cmd = build_rg_command()
  local seen_endpoints = {}  -- 用于去重的集合
  
  pickers.new({}, {
    prompt_title = "Spring Boot Endpoint",
    finder = finders.new_oneshot_job(cmd, {
      entry_maker = function(line)
        local parsed = parse_rg_line(line)
        if not parsed then return nil end
        
        -- 提取端点信息
        local endpoint_info = extract_endpoint_info(parsed.filename, parsed.lnum)
        
        -- 只处理有有效路径的端点
        if not endpoint_info or endpoint_info.path == "" then
          return nil
        end
        
        -- 基于路径+HTTP方法去重（简单有效）
        local unique_key = endpoint_info.path .. "|" .. (endpoint_info.method_type or "Request")
        
        -- 如果已经见过这个端点，跳过
        if seen_endpoints[unique_key] then
          return nil
        end
        
        -- 标记为已见过
        seen_endpoints[unique_key] = true
        
        return {
          value = line,
          display = function(entry)
            return format_entry(entry)
          end,
          ordinal = endpoint_info.path .. " " .. endpoint_info.class_name .. " " .. endpoint_info.method_name .. " " .. parsed.filename,
          filename = parsed.filename,
          lnum = endpoint_info.actual_line,  -- 使用实际的映射注解行号
          col = 1,  -- 定位到行首
          text = parsed.text,
          endpoint_info = endpoint_info,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = create_previewer(),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd("edit " .. selection.filename)
          vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })  -- 定位到行首
          -- 确保居中操作在下一个事件循环中执行
          vim.schedule(function()
            vim.cmd("normal! zz")  -- 居中显示当前行
          end)
        end
      end)
      
      -- 添加复制路径功能
      map("n", "<C-y>", function()
        local selection = action_state.get_selected_entry()
        if selection and selection.endpoint_info and selection.endpoint_info.path ~= "" then
          vim.fn.setreg("+", selection.endpoint_info.path)
          vim.notify("已复制路径: " .. selection.endpoint_info.path, vim.log.levels.INFO)
        end
      end)
      
      return true
    end,
  }):find()
end

return M
