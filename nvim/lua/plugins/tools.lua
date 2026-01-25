return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      file_types = { "markdown", "vimwiki" },
      anti_conceal = {
        enabled = false,
      },
    },
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
    "rcarriga/nvim-notify",
    config = function()
      vim.notify = require("notify")
    end,
  },
}
