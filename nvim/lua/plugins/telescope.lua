return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      {
        "<leader>ft",
        "<cmd>Telescope<cr>",
        desc = "Telescope",
      },
      {
        "<leader>ff",
        "<cmd>Telescope find_files<cr>",
        desc = "Find files",
      },
      {
        "<leader>fa",
        "<cmd>Telescope find_files hidden=true no_ignore=true<cr>",
        desc = "Find all files",
      },
      {
        "<leader>fg",
        "<cmd>Telescope git_status<cr>",
        desc = "Show git status",
      },
      {
        "<leader>fr",
        "<cmd>Telescope live_grep<cr>",
        desc = "Live grep",
      },
      {
        "<leader>fs",
        "<cmd>Telescope current_buffer_fuzzy_find<cr>",
        desc = "Fuzzy find in current buffer",
      },
      {
        "<leader>fb",
        "<cmd>Telescope buffers<cr>",
        desc = "Find buffers",
      },
      {
        "<leader>fp",
        "<cmd>Telescope resume<cr>",
        desc = "Resume last search",
      },
      {
        "<leader>fo",
        "<cmd>Telescope oldfiles only_cwd=true<cr>",
        desc = "List old files",
      },
      {
        "<leader>fh",
        "<cmd>Telescope help_tags<cr>",
        desc = "Help tags",
      },
    },
    opts = {
      defaults = {
        wrap_results = true,
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            width = 0.9,
            preview_width = 0.45,
          },
          vertical = {
            preview_height = 0.5,
            preview_cutoff = 0,
            mirror = false,
          },
        },
        mappings = {
          i = {
            ["<C-q>"] = require("telescope.actions").smart_send_to_qflist + require("telescope.actions").open_qflist,
            ["<C-n>"] = require("telescope.actions").cycle_history_next,
            ["<C-p>"] = require("telescope.actions").cycle_history_prev,
          },
        },
        path_display = { "filename_first" },
      },
      pickers = {
        find_files = {
          follow = true,
        },
        live_grep = {
          additional_args = { "--follow" },
          mappings = {
            i = {
              ["<C-f>"] = function(prompt_bufnr)
                local current_text = require("telescope.actions.state").get_current_line()

                vim.ui.input({ prompt = "Enter rg parameters (e.g., -t lua, --glob *.rs): " }, function(input)
                  if input == nil then
                    return
                  end

                  local builtin = require("telescope.builtin")
                  local opts = {
                    default_text = current_text,
                    additional_args = function()
                      if input == "" then
                        return {}
                      end
                      -- Parse the input string into a table
                      local args = {}
                      for arg in input:gmatch("[^ ]+") do
                        table.insert(args, arg)
                      end
                      return args
                    end,
                  }

                  -- Close current picker and reopen with new args
                  require("telescope.actions").close(prompt_bufnr)
                  builtin.live_grep(opts)
                end)
              end,
            },
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
      require("telescope").setup(opts)
      pcall(require("telescope").load_extension, "coc")
      require("telescope").load_extension("fzf")
    end,
  },
}
