return {
  {
    "voldikss/vim-floaterm",
    lazy = false,
    init = function()
      -- These need to be set BEFORE the plugin loads
      vim.g.floaterm_width = 0.9
      vim.g.floaterm_height = 0.9
      vim.g.floaterm_keymap_toggle = '<C-Space><C-Space>'
      vim.g.floaterm_borderchars = '─│─│╭╮╯╰]'
    end,
    config = function()
      vim.cmd([[hi FloatermBorder guibg=#222433]])
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npx --yes yarn install",
    ft = "markdown",
  },
  {
    "rhysd/vim-grammarous",
  },
  {
    "mattn/emmet-vim",
  },
  {
    "github/copilot.vim",
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      file_types = { 'markdown', 'vimwiki' },
    },
  },
}
