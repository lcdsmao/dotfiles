return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false,                    -- neo-tree will lazily load itself
    keys = {
      { "<leader>nn", "<cmd>Neotree float reveal<cr>",     desc = "Open NeoTree File" },
      { "<leader>ng", "<cmd>Neotree float git_status<cr>", desc = "Open NeoTree Git" },
    },
    opts = {
      window = {
        mappings = {
          ["z"] = "noop",
          ["Z"] = "close_all_nodes",
          ["h"] = "close_node",
          ["l"] = "open",
        },
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    }
  },
  {
    "mikavilpas/yazi.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      { "<leader>nf", "<cmd>Yazi<cr>",        desc = "Open yazi at the current file" },
      { "<leader>nw", "<cmd>Yazi cwd<cr>",    desc = "Open the file manager in nvim's working directory" },
      { "<leader>nn", "<cmd>Yazi toggle<cr>", desc = "Resume the last yazi session" },
    },
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = true,
      floating_window_scaling_factor = 0.8,
      keymaps = {},
    },
    init = function()
      -- 👇 if you use `open_for_directories=true`, this is recommended
      -- mark netrw as loaded so it's not loaded at all.
      -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
      vim.g.loaded_netrwPlugin = 1
    end,
  }
}
