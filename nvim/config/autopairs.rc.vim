UsePlugin 'nvim-autopairs'
UsePlugin 'nvim-treesitter'

lua << EOF
require('nvim-autopairs').setup {}

require('nvim-treesitter').setup {
  autopairs = {
    enable = true
  }
}
EOF
