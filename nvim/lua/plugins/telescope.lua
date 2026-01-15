return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = 'make' },
    },
    keys = {
      { "<leader>ft", "<cmd>Telescope<cr>", desc = "Telescope" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find git files" },
      { "<leader>fa", "<cmd>Telescope find_files hidden=true no_ignore=true<cr>", desc = "Find all files" },
      { "<leader>fr", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
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
    end,
  },
}
