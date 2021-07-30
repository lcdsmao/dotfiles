UsePlugin 'nvim-autopairs'
UsePlugin 'nvim-treesitter'

lua << EOF
require('nvim-autopairs').setup {}

require('nvim-treesitter.configs').setup {
  autopairs = {
    enable = true
  }
}
EOF
