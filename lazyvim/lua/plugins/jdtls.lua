-- -- Java LSP 配置 - 仅用于代码阅读和导航
-- return {
--   -- Treesitter: Java 语法高亮
--   {
--     "nvim-treesitter/nvim-treesitter",
--     opts = {
--       ensure_installed = { "java" },
--     },
--   },

--   -- Mason: 自动安装 jdtls
--   {
--     "mason-org/mason.nvim",
--     opts = {
--       ensure_installed = { "jdtls" },
--     },
--   },

--   -- LSP Config: 配置 jdtls 但延迟启动
--   {
--     "neovim/nvim-lspconfig",
--     opts = {
--       servers = {
--         jdtls = {},
--       },
--       setup = {
--         jdtls = function()
--           return true -- 避免重复启动，由 nvim-jdtls 接管
--         end,
--       },
--     },
--   },

--   -- JDTLS: 核心 Java LSP 配置（最小化，仅用于代码阅读）
--   {
--     "mfussenegger/nvim-jdtls",
--     ft = { "java" },
--     opts = function()
--       -- jdtls 需要 Java 21 运行，但项目可以用 Java 8
--       local java21_home = "/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home"
--       local java8_home = "/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home"
      
--       local cmd = { 
--         vim.fn.exepath("jdtls"),
--         -- 指定 jdtls 使用 Java 21 运行
--         string.format("--jvm-arg=-Djava.home=%s", java21_home),
--       }
      
--       -- 如果使用 mason 安装了 lombok，添加支持
--       if LazyVim.has("mason.nvim") then
--         local lombok_jar = vim.fn.expand("$MASON/share/jdtls/lombok.jar")
--         if vim.fn.filereadable(lombok_jar) == 1 then
--           table.insert(cmd, string.format("--jvm-arg=-javaagent:%s", lombok_jar))
--         end
--       end

--       return {
--         -- 根目录检测
--         root_dir = function(path)
--           return vim.fs.root(path, {
--             ".git",
--             "mvnw",
--             "gradlew",
--             "pom.xml",
--             "build.gradle",
--           })
--         end,

--         -- 项目名称
--         project_name = function(root_dir)
--           return root_dir and vim.fs.basename(root_dir)
--         end,

--         -- 配置目录
--         jdtls_config_dir = function(project_name)
--           return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
--         end,

--         -- 工作区目录
--         jdtls_workspace_dir = function(project_name)
--           return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
--         end,

--         cmd = cmd,

--         -- 构建完整启动命令
--         full_cmd = function(opts)
--           local fname = vim.api.nvim_buf_get_name(0)
--           local root_dir = opts.root_dir(fname)
--           local project_name = opts.project_name(root_dir)
--           local cmd = vim.deepcopy(opts.cmd)
          
--           if project_name then
--             vim.list_extend(cmd, {
--               "-configuration",
--               opts.jdtls_config_dir(project_name),
--               "-data",
--               opts.jdtls_workspace_dir(project_name),
--             })
--           end
          
--           return cmd
--         end,

--         -- 禁用 DAP 和测试支持（不需要）
--         dap = false,
--         dap_main = false,
--         test = false,

--         -- LSP 基本设置
--         settings = {
--           java = {
--             -- 配置 Java 运行时（项目使用 Java 8，但 jdtls 用 Java 21）
--             configuration = {
--               runtimes = {
--                 {
--                   name = "JavaSE-1.8",
--                   path = java8_home,
--                   default = true,
--                 },
--                 {
--                   name = "JavaSE-21",
--                   path = java21_home,
--                 },
--               },
--             },
--             -- 启用参数名提示（阅读代码时很有用）
--             inlayHints = {
--               parameterNames = {
--                 enabled = "all",
--               },
--             },
--             -- 禁用自动导入组织
--             saveActions = {
--               organizeImports = false,
--             },
--           },
--         },
--       }
--     end,

--     config = function(_, opts)
--       -- 附加 jdtls 到 Java 文件
--       local function attach_jdtls()
--         local fname = vim.api.nvim_buf_get_name(0)
        
--         -- 临时设置 JAVA_HOME 为 Java 21（仅用于启动 jdtls）
--         local original_java_home = vim.fn.getenv("JAVA_HOME")
--         vim.fn.setenv("JAVA_HOME", "/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home")
        
--         local config = {
--           cmd = opts.full_cmd(opts),
--           root_dir = opts.root_dir(fname),
--           settings = opts.settings,
--           init_options = {
--             bundles = {}, -- 不需要调试和测试的 bundles
--           },
--           -- LSP 基本能力
--           capabilities = LazyVim.has("blink.cmp") and require("blink.cmp").get_lsp_capabilities()
--             or LazyVim.has("cmp-nvim-lsp") and require("cmp_nvim_lsp").default_capabilities()
--             or nil,
--         }

--         require("jdtls").start_or_attach(config)
        
--         -- 恢复原始 JAVA_HOME
--         if original_java_home and original_java_home ~= vim.NIL then
--           vim.fn.setenv("JAVA_HOME", original_java_home)
--         end
--       end

--       -- 为每个 Java 文件自动附加 jdtls
--       vim.api.nvim_create_autocmd("FileType", {
--         pattern = { "java" },
--         callback = attach_jdtls,
--       })

--       -- 首次加载时立即附加
--       attach_jdtls()
--     end,
--   },
-- }


return {}