return {
  "mfussenegger/nvim-jdtls",
  ft = "java",
  -- 条件加载：检测 Java 项目
  cond = function()
    local cwd = vim.fn.getcwd()
    return vim.fn.filereadable(cwd .. "/pom.xml") == 1 
      or vim.fn.filereadable(cwd .. "/build.gradle") == 1
      or vim.fn.filereadable(cwd .. "/build.gradle.kts") == 1
      or vim.fn.isdirectory(cwd .. "/src/main/java") == 1
  end,
  config = function()
    -- nvim-jdtls 使用 config 而不是 opts
    local jdtls = require("jdtls")
    
    local config = {
      cmd = {
        "jdtls",
        "--jvm-arg=-javaagent:" .. vim.fn.stdpath("data") .. "/mason/packages/jdtls/lombok.jar",
      },
      root_dir = jdtls.setup.find_root({".git", "mvnw", "gradlew", "pom.xml", "build.gradle"}),
      settings = {
        java = {
          -- 启用 Lombok 注解处理器
          eclipse = {
            downloadSources = true,
          },
          compile = {
            nullAnalysis = {
              mode = "automatic",
            },
          },
        },
      },
      init_options = {
        extendedClientCapabilities = {
          -- Lombok 相关扩展能力
          lombokSupport = true,
          resolveAdditionalTextEditsSupport = true,
        },
      },
    }
    
    jdtls.start_or_attach(config)
  end,
}
