return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false, -- neo-tree will lazily load itself
    keys = {
      { "<leader>nn", "<cmd>Neotree float reveal<cr>", desc = "Open NeoTree File" },
      { "<leader>ng", "<cmd>Neotree float git_status<cr>", desc = "Open NeoTree Git" },
    },
    opts = {
      window = {
        mappings = {
          ["z"] = "noop",
          ["Z"] = "close_all_nodes",
          ["h"] = "close_node",
          ["l"] = "open",
          ["gs"] = function(state)
            local reveal_file = vim.fn.expand("#:p")
            if reveal_file ~= "" then
              require("neo-tree.command").execute({ action = "focus", reveal_file = reveal_file, dir = vim.fn.getcwd() })
            end
          end,
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
