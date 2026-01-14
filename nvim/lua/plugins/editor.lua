return {
  {
    "tpope/vim-surround",
  },
  {
    "tpope/vim-commentary",
  },
  {
    "godlygeek/tabular",
  },
  {
    "terryma/vim-multiple-cursors",
  },
  {
    "editorconfig/editorconfig-vim",
  },
  {
    "AndrewRadev/splitjoin.vim",
  },
  {
    "windwp/nvim-autopairs",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
    config = function(_, opts)
      require('nvim-autopairs').setup(opts)
      require('nvim-treesitter').setup {
        autopairs = {
          enable = true
        }
      }
    end,
  },
  {
    "bfredl/nvim-miniyank",
    config = function()
      vim.keymap.set('', 'p', '<Plug>(miniyank-autoput)')
      vim.keymap.set('', 'P', '<Plug>(miniyank-autoPut)')
    end,
  },
  {
    "honza/vim-snippets",
  },
  {
    "kevinhwang91/nvim-bqf",
  },
}
