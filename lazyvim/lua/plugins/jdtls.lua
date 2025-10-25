return {
  "mfussenegger/nvim-jdtls",
  ft = "java",
  -- 条件加载：检测 Java 项目
  cond = function()
    local cwd = vim.fn.getcwd()
    return vim.fn.filereadable(cwd .. "/pom.xml") == 1
  end,
  config = function()
    -- nvim-jdtls 使用 config 而不是 opts
    local jdtls = require("jdtls")
    
    -- 获取项目根目录（直接使用当前工作目录，适用于多模块项目）
    local root_dir = vim.fn.getcwd()
    
    -- 配置工作空间目录，避免多模块项目在子模块中创建.project
    local project_name = vim.fn.fnamemodify(root_dir, ':t')
    local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name
    
    -- jdtls 运行需要 Java 21，但项目可能使用 Java 8
    local java_21_home = "/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home"
    local jdtls_install = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
    
    local config = {
      -- 直接使用 Java 21 启动 jdtls，不使用 jdtls 包装脚本
      cmd = {
        java_21_home .. "/bin/java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.level=ALL",
        "-Xmx1G",
        "--add-modules=ALL-SYSTEM",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
        "-javaagent:" .. jdtls_install .. "/lombok.jar",
        "-jar", vim.fn.glob(jdtls_install .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
        "-configuration", jdtls_install .. "/config_mac",
        "-data", workspace_dir,
      },
      root_dir = root_dir,
      
      -- 禁用 LSP 自动格式化
      on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
      settings = {
        java = {
          -- java.home 已废弃，移除此配置
          -- 内联提示：显示参数名称
          inlayHints = {
            parameterNames = {
              enabled = "all", -- 显示所有参数名称提示
            },
          },
          -- 启用 Lombok 注解处理器
          eclipse = {
            downloadSources = true,
          },
          compile = {
            nullAnalysis = {
              mode = "automatic",
            },
          },
          -- 多模块项目配置
          configuration = {
            updateBuildConfiguration = "automatic",
            maven = {
              downloadSources = true,
            },
            gradle = {
              downloadSources = true,
            },
          },
          -- 改进项目导入配置
          import = {
            maven = {
              enabled = true,
            },
            gradle = {
              enabled = true,
              wrapper = {
                enabled = true,
              },
            },
          },
          -- 多模块项目特定设置
          project = {
            referencedLibraries = {},
          },
          references = {
            includeDecompiledSources = true,
          },
          signatureHelp = {
            enabled = true,
          },
          contentProvider = {
            preferred = "fernflower",
          },
          -- 确保多模块项目正确解析
          completion = {
            favoriteStaticMembers = {},
            importOrder = {},
          },
        },
      },
      init_options = {
        extendedClientCapabilities = {
          -- Lombok 相关扩展能力
          lombokSupport = true,
          resolveAdditionalTextEditsSupport = true,
          -- 多模块项目支持
          classFileContentsSupport = true,
          generateToStringPromptSupport = true,
          hashCodeEqualsPromptSupport = true,
          advancedExtractRefactoringSupport = true,
          advancedOrganizeImportsSupport = true,
          generateConstructorsPromptSupport = true,
          generateDelegateMethodsPromptSupport = true,
          moveRefactoringSupport = true,
        },
        -- 让 JDTLS 自动发现多模块项目
        bundles = {},
      },
    }
    
    jdtls.start_or_attach(config)
  end,
}
