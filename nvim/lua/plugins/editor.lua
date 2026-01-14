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
    "tpope/vim-sleuth",
  },
  {
    "AndrewRadev/splitjoin.vim",
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      map_cr = false,
    },
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
