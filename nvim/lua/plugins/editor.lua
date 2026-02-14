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
    config = true,
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
    opts = {
      preview = {
        winblend = 0,
      },
    },
  },
  {
    "echasnovski/mini.bufremove",
    version = "*",
    keys = {
      {
        "<leader>x",
        function()
          require("mini.bufremove").delete(0, false)
        end,
        desc = "Close buffer",
      },
    },
    config = function()
      require("mini.bufremove").setup()
    end,
  },
}
