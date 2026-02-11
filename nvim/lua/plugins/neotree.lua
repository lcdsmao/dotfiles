return {
  {
    "nvim-neo-tree/neo-tree.nvim",
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
}
