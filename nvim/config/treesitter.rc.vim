UsePlugin 'nvim-treesitter'

lua <<eof
require('nvim-treesitter').install {
  "markdown",
  "markdown_inline",
  "lua",
  "vim",
  "vimdoc",
  "query",
  "javascript",
  "typescript",
  "python",
  "rust",
  "go",
  "java",
  "c",
  "cpp",
}
eof
