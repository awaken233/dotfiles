-- endpoint.nvim 插件配置：提供跨框架 API 端点模糊搜索
return {
  {
    "zerochae/endpoint.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    cmd = { "Endpoint", "EndpointRefresh" },
    keys = {
      {
        "gl",
        function()
          require("endpoint").find({})
        end,
        desc = "Endpoint: search",
      },
    },
    -- 添加条件加载：检测是否为 Spring Boot 项目
    cond = function()
      local cwd = vim.fn.getcwd()
      -- 检查是否存在 Spring Boot 相关文件
      return vim.fn.filereadable(cwd .. "/pom.xml") == 1 
        or vim.fn.filereadable(cwd .. "/build.gradle") == 1
        or vim.fn.filereadable(cwd .. "/build.gradle.kts") == 1
        or vim.fn.isdirectory(cwd .. "/src/main/java") == 1
    end,
    config = function()
      require("endpoint").setup({
        picker = {
          type = "telescope",
          options = {
            telescope = {
            },
          },
        },
        cache = {
          mode = "session",
        },
      })
    end,
  },
}