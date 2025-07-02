-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

opt.clipboard = ""
opt.expandtab = false -- Use spaces instead of tabs

-- 配置代理环境变量
vim.env.http_proxy = "http://127.0.0.1:7890"
vim.env.https_proxy = "http://127.0.0.1:7890"
vim.env.all_proxy = "socks5://127.0.0.1:7890"
