return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "fannheyward/telescope-coc.nvim",
    },
    opts = {
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
        coc = {
          prefer_locations = true,
          push_cursor_on_edit = true,
        },
      },
    },
    config = function(_, opts)
      require('telescope').setup(opts)
      pcall(require('telescope').load_extension, 'coc')

      -- Keymaps
      vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>')
      vim.keymap.set('n', '<leader>fg', '<cmd>Telescope git_files<cr>')
      vim.keymap.set('n', '<leader>fr', '<cmd>Telescope live_grep<cr>')
      vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>')
    end,
  },
}
