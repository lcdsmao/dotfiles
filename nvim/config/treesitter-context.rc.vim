UsePlugin 'nvim-treesitter'
UsePlugin 'nvim-treesitter-context'

hi TreesitterContext ctermfg=103 ctermbg=238 guifg=#8085a6 guibg=#32364c

lua <<eof
require('treesitter-context').setup {
  enable = true,
}
eof
