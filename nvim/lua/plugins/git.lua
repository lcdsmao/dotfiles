return {
  {
    "airblade/vim-gitgutter",
    config = function()
      vim.keymap.set('n', ']h', '<Plug>(GitGutterNextHunk)')
      vim.keymap.set('n', '[h', '<Plug>(GitGutterPrevHunk)')
      vim.keymap.set('n', 'ghs', '<Plug>(GitGutterStageHunk)')
      vim.keymap.set('n', 'ghu', '<Plug>(GitGutterUndoHunk)')
      vim.keymap.set('n', 'ghp', '<Plug>(GitGutterPreviewHunk)')
    end,
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
