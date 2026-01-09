UsePlugin 'telescope.nvim'
UsePlugin 'popup.nvim'
UsePlugin 'plenary.nvim'
UsePlugin 'telescope-coc.nvim'

lua << EOF
require('telescope').setup({
  defaults = {
    layout_config = {
      horizontal = {
        preview_width = 0.55,
        results_width = 0.8,
      },
      vertical = {
        mirror = false,
      },
    },
    mappings = {
      i = {
        ["<C-n>"] = require('telescope.actions').cycle_history_next,
        ["<C-p>"] = require('telescope.actions').cycle_history_prev,
      },
    },
  },
  extensions = {
    -- codecompanion = {
    --   prompt_title = "CodeCompanion Actions",
    -- },
    coc = {
      -- COC extension settings
      prefer_locations = true, -- always use Telescope locations to preview definitions/declarations/implementations etc
      push_cursor_on_edit = true, -- save the cursor position to jump back in the future
    },
  },
})

-- Load extensions with error protection
-- pcall(require('telescope').load_extension, 'codecompanion')
pcall(require('telescope').load_extension, 'coc')
EOF

" Pickers
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope git_files<cr>
nnoremap <leader>fr <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
" nnoremap <leader>fc <cmd>Telescope codecompanion<cr>
