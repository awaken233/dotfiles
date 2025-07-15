-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap
local unmap = vim.keymap.del

-- clipboard
keymap.set("n", "<leader>yo", "<cmd>let @+ = @0<CR>", { desc = "exchange clipboard to system" })
keymap.set("n", "t", "F")
keymap.set("n", "vv", "V")
keymap.set({ "n", "v" }, "<C-a>", "^")
keymap.set({ "n", "v" }, "<C-e>", "$")
keymap.set({ "i" }, "<C-a>", "<home>")
keymap.set({ "i" }, "<C-e>", "<end>")

-- 取消 Alt+j/k 映射，避免在 tmux 中的按键冲突
unmap({ "n", "i", "v" }, "<A-j>")
unmap({ "n", "i", "v" }, "<A-k>")
