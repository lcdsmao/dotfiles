UsePlugin 'render-markdown.nvim'

lua << EOF
require('render-markdown').setup({
    file_types = { 'markdown', 'vimwiki' },
})
EOF
