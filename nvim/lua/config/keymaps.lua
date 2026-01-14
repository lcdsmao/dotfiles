-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- Navigation
map("n", "<leader>a", "^", { desc = "Go to beginning of line" })
map("n", "<leader>e", "$", { desc = "Go to end of line" })

-- Split
map("n", "<leader>ss", ":split<CR>", { desc = "Horizontal split" })
map("n", "<leader>sv", ":vsplit<CR>", { desc = "Vertical split" })

-- Paste
map("n", "<C-p>", ":pu<CR>", { desc = "Paste below" })

-- Yank without cursor moving
map("v", "y", "ygv<ESC>", { desc = "Yank without cursor move" })

-- Fast saving
map("n", "<leader>w", ":w!<CR>", { desc = "Save file" })

-- Terminal mode
map("t", "<C-j><C-j>", "<C-\\><C-n>", { desc = "Exit terminal mode", silent = true })

-- Disable highlight
map("n", "<leader><CR>", ":noh<CR>", { desc = "Clear search highlight", silent = true })

-- Window navigation
map("n", "<C-j>", "<C-W>j", { desc = "Move to window below" })
map("n", "<C-k>", "<C-W>k", { desc = "Move to window above" })
map("n", "<C-h>", "<C-W>h", { desc = "Move to window left" })
map("n", "<C-l>", "<C-W>l", { desc = "Move to window right" })

-- Buffer management
map("n", "<leader>ba", ":bufdo bd<CR>", { desc = "Close all buffers" })
map("n", "<leader>l", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>h", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>tt", ":b#<CR>", { desc = "Toggle buffer" })

-- Change working directory
map("n", "<leader>cd", ":cd %:p:h<CR>:pwd<CR>", { desc = "CD to current file" })

-- Half page movement
map("n", "<leader>k", "<C-u>", { desc = "Move up half page" })
map("n", "<leader>j", "<C-d>", { desc = "Move down half page" })

-- Quickfix navigation
map("n", "[q", ":<C-u>cprevious<CR>", { desc = "Previous quickfix" })
map("n", "]q", ":<C-u>cnext<CR>", { desc = "Next quickfix" })
map("n", "[Q", ":<C-u>cfirst<CR>", { desc = "First quickfix" })
map("n", "]Q", ":<C-u>clast<CR>", { desc = "Last quickfix" })
