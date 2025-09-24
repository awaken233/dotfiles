return {
  "mfussenegger/nvim-jdtls",
  -- 只在 Java 文件中加载
  ft = "java",
  -- 添加条件加载：检测 Java 项目
  cond = function()
    local cwd = vim.fn.getcwd()
    return vim.fn.filereadable(cwd .. "/pom.xml") == 1 
      or vim.fn.filereadable(cwd .. "/build.gradle") == 1
      or vim.fn.filereadable(cwd .. "/build.gradle.kts") == 1
      or vim.fn.isdirectory(cwd .. "/src/main/java") == 1
  end,
  opts = {
    cmd = {
      "python3",
      vim.fn.stdpath("data") .. "/mason/packages/jdtls/bin/jdtls",
      "--java-executable",
      "/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home/bin/java",
      -- 添加 Lombok 支持
      "--jvm-arg=-javaagent:" .. vim.fn.stdpath("data") .. "/mason/packages/jdtls/lombok.jar",
    },
    -- Spring Boot 项目优化配置
    settings = {
      java = {
        -- 提升性能
        configuration = {
          updateBuildConfiguration = "interactive",
        },
        -- Lombok 支持配置
        compile = {
          nullAnalysis = {
            mode = "automatic",
          },
        },
        -- 启用注解处理器支持 Lombok
        eclipse = {
          downloadSources = true,
        },
        -- 代码完成优化
        completion = {
          favoriteStaticMembers = {
            "org.hamcrest.MatcherAssert.assertThat",
            "org.hamcrest.Matchers.*",
            "org.hamcrest.CoreMatchers.*",
            "org.junit.jupiter.api.Assertions.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
            "org.mockito.Mockito.*",
            -- Spring Boot 常用静态导入
            "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
            "org.springframework.test.web.servlet.result.MockMvcResultMatchers.*",
          },
        },
        -- 源码导入优化
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
        -- 代码生成
        codeGeneration = {
          toString = {
            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
          },
          useBlocks = true,
        },
      },
    },
    -- 初始化选项优化
    init_options = {
      bundles = {},
      extendedClientCapabilities = {
        progressReportProvider = false, -- 关闭进度报告以提升性能
        classFileContentsSupport = true,
        generateToStringPromptSupport = true,
        hashCodeEqualsPromptSupport = true,
        advancedExtractRefactoringSupport = true,
        advancedOrganizeImportsSupport = true,
        generateConstructorsPromptSupport = true,
        generateDelegateMethodsPromptSupport = true,
        moveRefactoringSupport = true,
        -- Lombok 相关扩展能力
        lombokSupport = true,
        resolveAdditionalTextEditsSupport = true,
      },
    },
  },
}
