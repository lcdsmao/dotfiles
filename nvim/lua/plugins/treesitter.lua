return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
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
