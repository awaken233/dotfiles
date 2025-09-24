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
    config = function()
      require("endpoint").setup({
        picker = {
          type = "telescope",
        },
        cache = {
          mode = "session",
        },
      })
    end,
  },
}

