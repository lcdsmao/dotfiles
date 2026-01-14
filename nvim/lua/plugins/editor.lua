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
    keys = {
      { "p", "<Plug>(miniyank-autoput)", mode = { "n", "x" }, desc = "Paste" },
      { "P", "<Plug>(miniyank-autoPut)", mode = { "n", "x" }, desc = "Paste before" },
    },
  },
  {
    "honza/vim-snippets",
  },
  {
    "kevinhwang91/nvim-bqf",
  },
}
