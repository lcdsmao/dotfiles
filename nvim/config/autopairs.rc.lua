vim.cmd([[
  UsePlugin 'nvim-autopairs'
  UsePlugin 'nvim-treesitter'
]])

require('nvim-autopairs').setup {}

require('nvim-treesitter.configs').setup {
  autopairs = {
    enable = true
  }
}
