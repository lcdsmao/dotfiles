-- Load legacy vimrc settings
vim.cmd('runtime init_legacy.vim')

-- Setup lazy.nvim
require("config.lazy")

-- Other configurations
require("config.cheatsheet")
