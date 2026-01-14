return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = function()
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
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      enable = true,
    },
    config = function(_, opts)
      vim.cmd([[hi TreesitterContext ctermfg=103 ctermbg=238 guifg=#8085a6 guibg=#32364c]])
      require('treesitter-context').setup(opts)
    end,
  },
}
