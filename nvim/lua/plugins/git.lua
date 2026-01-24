return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    keys = {
      { "]h", function() require('gitsigns').nav_hunk('next') end, desc = "Next hunk" },
      { "[h", function() require('gitsigns').nav_hunk('prev') end, desc = "Previous hunk" },
      { "ghs", function() require('gitsigns').stage_hunk() end, desc = "Stage hunk" },
      { "ghu", function() require('gitsigns').reset_hunk() end, desc = "Undo hunk" },
      { "ghp", function() require('gitsigns').preview_hunk() end, desc = "Preview hunk" },
      { "gbb", function() require('gitsigns').blame() end, desc = "Show blame" },
    },
  },
  {
    "tpope/vim-fugitive",
  },
  {
    "tpope/vim-rhubarb",
  },
  {
    "nvim-mini/mini.diff",
  },
}
