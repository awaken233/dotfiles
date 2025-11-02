-- return {
--   -- add gruvbox
--   -- { "ellisonleao/gruvbox.nvim" },
--
--   -- Configure LazyVim to load gruvbox
--   {
--     "LazyVim/LazyVim",
--     opts = {
--       colorscheme = "delek",
--     },
--   },
-- }

-- 根据系统主题自动切换配色:暗色使用 tokyonight-moon,亮色使用 delek
return {
  -- 添加 tokyonight 主题
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      -- 禁用自动检测 background,防止 tokyonight 自动切换到 day
      style = "moon",
    },
  },

  -- 配置 LazyVim 根据系统主题自动切换配色
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        vim.schedule(function()
          if vim.o.background == "light" then
            -- 亮色模式使用内置的 delek 主题
            vim.cmd("colorscheme catppuccin-latte")
          else
            -- 暗色模式使用 tokyonight-moon
            vim.cmd("colorscheme tokyonight-moon")
          end
        end)
      end,
    },
  },
}
