return {
  {
    "airblade/vim-gitgutter",
    event = "BufRead",
    keys = {
      { "]h", "<Plug>(GitGutterNextHunk)", desc = "Next hunk" },
      { "[h", "<Plug>(GitGutterPrevHunk)", desc = "Previous hunk" },
      { "ghs", "<Plug>(GitGutterStageHunk)", desc = "Stage hunk" },
      { "ghu", "<Plug>(GitGutterUndoHunk)", desc = "Undo hunk" },
      { "ghp", "<Plug>(GitGutterPreviewHunk)", desc = "Preview hunk" },
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
