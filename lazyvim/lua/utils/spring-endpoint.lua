-- Spring Boot API 端点搜索工具 (Performance Optimized)
local M = {}

local telescope = require("telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local utils = require("telescope.utils")

-- ============================================================================
-- 性能优化：缓存和预编译
-- ============================================================================

-- 全局缓存（单次搜索会话）
local file_cache = {}           -- 文件内容缓存
local class_info_cache = {}     -- 类信息缓存
local endpoint_cache = {}       -- 端点信息缓存

-- 预编译正则表达式（性能优化）
local patterns = {
  class_def = vim.regex([[\vpublic\s+class\s+(\w+)]]),
  request_mapping = vim.regex([[\v\@RequestMapping\s*\(\s*"([^"]*)"|\@RequestMapping\s*\(\s*value\s*\=\s*"([^"]*)"|\@RequestMapping\s*\(\s*path\s*\=\s*"([^"]*)"]]),
  method_mapping = vim.regex([[\v\@(\w*)Mapping\s*\(\s*"([^"]*)"|\@(\w*)Mapping\s*\(\s*value\s*\=\s*"([^"]*)"|\@(\w*)Mapping\s*\(\s*path\s*\=\s*"([^"]*)"]]),
  method_def = vim.regex([[\v(public|private).*(\w+)\s*\(]]),
  any_mapping = vim.regex([[\v\@\w*Mapping]]),
  not_request_mapping = vim.regex([[\v\@(Get|Post|Put|Delete|Patch)Mapping]]),
}

-- Spring Boot 端点映射注解模式
local SPRING_ANNOTATIONS = {
  "@GetMapping", 
  "@PostMapping",
  "@PutMapping",
  "@DeleteMapping",
  "@PatchMapping",
}


-- ============================================================================
-- 缓存管理
-- ============================================================================

-- 清理缓存
local function clear_cache()
  file_cache = {}
  class_info_cache = {}
  endpoint_cache = {}
end

-- 优化的文件读取（带缓存）
local function read_file_cached(file_path)
  if file_cache[file_path] then
    return file_cache[file_path]
  end

  local lines = vim.fn.readfile(file_path)
  if lines then
    file_cache[file_path] = lines
  end
  return lines
end

-- 优化的类信息解析
local function parse_class_info(lines)
  local class_line, class_name, class_mapping = nil, "", ""
  
  -- 查找主要类定义
  for i = 1, #lines do
    local line = lines[i] or ""
    local class_match = line:match("public%s+class%s+(%w+)")
    if class_match then
      class_line = i
      class_name = class_match
      break
    end
  end
  
  -- 查找类级别的 @RequestMapping
  if class_line then
    local start_line = math.max(1, class_line - 5)
    for i = start_line, class_line do
      local line = lines[i] or ""
      local mapping = line:match('@RequestMapping%s*%(%s*"([^"]*)"') or
                     line:match('@RequestMapping%s*%(%s*value%s*=%s*"([^"]*)"') or
                     line:match('@RequestMapping%s*%(%s*path%s*=%s*"([^"]*)"')
      if mapping then
        class_mapping = mapping
        break
      end
    end
  end
  
  return {
    class_line = class_line,
    class_name = class_name,
    class_mapping = class_mapping,
  }
end

-- 批量解析类信息（性能优化）
local function parse_class_info_batch(file_paths)
  for _, file_path in ipairs(file_paths) do
    if not class_info_cache[file_path] then
      local lines = read_file_cached(file_path)
      if lines then
        class_info_cache[file_path] = parse_class_info(lines)
      end
    end
  end
end

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

-- ============================================================================
-- 优化的端点信息提取
-- ============================================================================

-- 优化的路径构建
local function build_full_path(class_mapping, method_mapping)
  local full_path = ""
  
  -- 处理类级别路径
  if class_mapping and class_mapping ~= "" then
    full_path = class_mapping:match("^/") and class_mapping or ("/" .. class_mapping)
  end
  
  -- 处理方法级别路径
  if method_mapping and method_mapping ~= "" then
    if full_path ~= "" then
      local separator = method_mapping:match("^/") and "" or "/"
      full_path = full_path .. separator .. method_mapping
    else
      full_path = method_mapping:match("^/") and method_mapping or ("/" .. method_mapping)
    end
  end
  
  -- 清理路径
  return full_path:gsub("//+", "/")
end

-- 优化的端点信息提取（带缓存）
local function extract_endpoint_info_cached(file_path, line_num)
  local cache_key = file_path .. ":" .. line_num
  
  -- 检查缓存
  if endpoint_cache[cache_key] then
    return endpoint_cache[cache_key]
  end
  
  -- 获取文件内容（缓存）
  local lines = read_file_cached(file_path)
  if not lines then return nil end
  
  -- 获取类信息（缓存）
  if not class_info_cache[file_path] then
    class_info_cache[file_path] = parse_class_info(lines)
  end
  local class_info = class_info_cache[file_path]
  
  -- 解析方法级别信息
  local method_mapping = ""
  local method_name = ""
  local method_type = ""
  local mapping_annotation_line = line_num
  
  -- 查找方法级别的映射注解（优化搜索范围）
  for i = line_num, math.min(#lines, line_num + 5) do
    local line = lines[i] or ""
    
    if line:match("@%w*Mapping") and not line:match("@RequestMapping") then
      method_type = line:match("@(%w*)Mapping") or ""
      local mapping = line:match('@%w*Mapping%s*%(%s*"([^"]*)"') or
                     line:match('@%w*Mapping%s*%(%s*value%s*=%s*"([^"]*)"') or
                     line:match('@%w*Mapping%s*%(%s*path%s*=%s*"([^"]*)"')
      if mapping then
        method_mapping = mapping
        mapping_annotation_line = i
        break
      end
    end
  end
  
  -- 查找方法名（优化搜索范围）
  for i = mapping_annotation_line, math.min(#lines, mapping_annotation_line + 5) do
    local line = lines[i] or ""
    if line:match("public.*%w+%s*%(") or line:match("private.*%w+%s*%(") then
      method_name = line:match("%w+%s+(%w+)%s*%(") or line:match("(%w+)%s*%(")
      break
    end
  end
  
  -- 构建完整路径（优化逻辑）
  local full_path = build_full_path(class_info.class_mapping, method_mapping)
  
  local result = {
    path = full_path,
    class_name = class_info.class_name,
    method_name = method_name,
    method_type = method_type,
    class_mapping = class_info.class_mapping,
    method_mapping = method_mapping,
    actual_line = mapping_annotation_line,
  }
  
  -- 缓存结果
  endpoint_cache[cache_key] = result
  return result
end

-- 批量预处理端点
local function preprocess_endpoints_batch(rg_results)
  local file_paths = {}
  local file_set = {}
  
  -- 收集唯一文件路径
  for _, result in ipairs(rg_results) do
    if not file_set[result.filename] then
      file_set[result.filename] = true
      table.insert(file_paths, result.filename)
    end
  end
  
  -- 批量解析类信息
  parse_class_info_batch(file_paths)
  
  return file_paths
end

-- ============================================================================
-- 显示和预览优化
-- ============================================================================

-- 优化的预览器
local function create_optimized_previewer()
  local last_entry = nil
  
  return previewers.new_buffer_previewer({
    title = "API 端点代码预览",
    get_buffer_by_name = function(_, entry)
      return entry.filename
    end,
    define_preview = function(self, entry, status)
      -- 避免重复预览同一个条目
      if last_entry and last_entry.filename == entry.filename and last_entry.lnum == entry.lnum then
        return
      end
      last_entry = entry
      
      conf.buffer_previewer_maker(entry.filename, self.state.bufnr, {
        bufname = self.state.bufname,
        winid = self.state.winid,
        preview = {
          msg = entry.filename,
        },
        callback = function(bufnr)
          -- 清除所有之前的高亮
          vim.api.nvim_buf_clear_namespace(bufnr, -1, 0, -1)
          
          -- 高亮当前端点行
          vim.api.nvim_buf_add_highlight(bufnr, -1, "CursorLine", entry.lnum - 1, 0, -1)
          
          -- 定位和居中（优化执行）
          pcall(vim.api.nvim_win_set_cursor, status.preview_win, { entry.lnum, 0 })
          vim.defer_fn(function()
            if vim.api.nvim_win_is_valid(status.preview_win) then
              vim.api.nvim_win_call(status.preview_win, function()
                vim.cmd("normal! zz")
              end)
            end
          end, 10)  -- 减少延迟
        end,
      })
    end,
  })
end


-- ============================================================================
-- 主搜索函数 (Performance Optimized)
-- ============================================================================

function M.search_spring_endpoints()
  clear_cache()
  
  -- 检查项目类型
  local cwd = vim.fn.getcwd()
  if vim.fn.isdirectory(cwd .. "/src") == 0 and vim.fn.filereadable(cwd .. "/pom.xml") == 0 then
    vim.notify("当前目录似乎不是 Java 项目", vim.log.levels.WARN)
  end
  
  -- 使用同步方式收集ripgrep结果（优化批量处理）
  local cmd = build_rg_command()
  local job = require("plenary.job")
  local rg_results = {}
  
  local job_obj = job:new({
    command = cmd[1],
    args = vim.list_slice(cmd, 2),
    on_stdout = function(_, line)
      local parsed = parse_rg_line(line)
      if parsed then
        table.insert(rg_results, parsed)
      end
    end,
  })
  
  job_obj:sync()
  
  -- 批量预处理（性能优化）
  preprocess_endpoints_batch(rg_results)
  
  -- 提前去重和过滤
  local unique_endpoints = {}
  local seen_keys = {}
  
  for _, parsed in ipairs(rg_results) do
    -- 懒加载：只在需要时解析详细信息
    local endpoint_info = extract_endpoint_info_cached(parsed.filename, parsed.lnum)
    
    if endpoint_info and endpoint_info.path ~= "" then
      local unique_key = endpoint_info.path .. "|" .. (endpoint_info.method_type or "Request")
      
      if not seen_keys[unique_key] then
        seen_keys[unique_key] = true
        
        -- 预先格式化显示文本
        local method_map = {
          Get = "GET",
          Post = "POST", 
          Put = "PUT",
          Delete = "DELETE",
          Patch = "PATCH",
          Request = "ALL"
        }
        local http_method = method_map[endpoint_info.method_type] or "UNKNOWN"
        local display_text = string.format("%-6s %s", http_method, endpoint_info.path)
        
        -- 安全的字符串连接，确保所有字段都是字符串
        local class_name = endpoint_info.class_name or ""
        local method_name = endpoint_info.method_name or ""
        local path = endpoint_info.path or ""
        local ordinal_text = path .. " " .. class_name .. " " .. method_name .. " " .. parsed.filename
        
        table.insert(unique_endpoints, {
          value = parsed.filename .. ":" .. parsed.lnum,
          display = display_text,
          ordinal = ordinal_text,
          filename = parsed.filename,
          lnum = endpoint_info.actual_line,
          col = 1,
          text = parsed.text,
          endpoint_info = endpoint_info,
        })
      end
    end
  end
  
  if #unique_endpoints == 0 then
    vim.notify("未找到任何 Spring Boot API 端点", vim.log.levels.INFO)
    return
  end
  
  -- 创建优化的 telescope picker
  pickers.new({}, {
    prompt_title = string.format("Spring Boot Endpoint (%d endpoints)", #unique_endpoints),
    finder = finders.new_table({
      results = unique_endpoints,
      entry_maker = function(entry)
        -- 确保所有字段都是正确类型
        return {
          value = entry.value,
          display = tostring(entry.display),
          ordinal = tostring(entry.ordinal),
          filename = entry.filename,
          lnum = entry.lnum,
          col = entry.col,
          endpoint_info = entry.endpoint_info,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = create_optimized_previewer(),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd("edit " .. selection.filename)
          vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
          vim.schedule(function()
            vim.cmd("normal! zz")
          end)
        end
        -- 搜索结束后清理缓存
        vim.schedule(function()
          clear_cache()
        end)
      end)
      
      -- 复制路径功能
      map("n", "<C-y>", function()
        local selection = action_state.get_selected_entry()
        if selection and selection.endpoint_info and selection.endpoint_info.path ~= "" then
          vim.fn.setreg("+", selection.endpoint_info.path)
          vim.notify("已复制路径: " .. selection.endpoint_info.path, vim.log.levels.INFO)
        end
      end)
      
      -- Escape 时清理缓存
      map("i", "<esc>", function()
        actions.close(prompt_bufnr)
        vim.schedule(function()
          clear_cache()
        end)
      end)
      
      return true
    end,
  }):find()
end

return M
