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

-- 交换 gI 和 gi 的功能
-- 默认: gI = 跳转到实现, gi = 跳转到上次插入位置并进入插入模式
-- 交换后: gI = 跳转到上次插入位置并进入插入模式, gi = 跳转到实现
keymap.set("n", "gI", "gi", { desc = "Goto last insert position" })
keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Goto Implementation" })

-- 交换 gy 和 gt 的功能  
-- 默认: gy = 跳转到类型定义, gt = 跳转到下一个标签页
-- 交换后: gy = 跳转到下一个标签页, gt = 跳转到类型定义
keymap.set("n", "gy", "gt", { desc = "Goto next tab" })
keymap.set("n", "gt", vim.lsp.buf.type_definition, { desc = "Goto Type Definition" })

-- 所有 yank 操作自动复制到系统剪贴板
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Auto copy yank to system clipboard",
  pattern = "*",
  callback = function()
    if vim.v.event.operator == "y" then
      vim.fn.setreg("+", vim.fn.getreg("0"))
    end
  end,
})

-- 选择整个文件内容的对象 (vie, vae, die, dae, yie, yae 等)
keymap.set({"o", "x"}, "ie", ":<C-U>normal! ggVG<CR>", { desc = "Select entire file content" })
keymap.set({"o", "x"}, "ae", ":<C-U>normal! ggVG<CR>", { desc = "Select entire file content" })
