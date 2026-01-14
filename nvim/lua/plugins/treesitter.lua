return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function(_, opts)
      local treesitter = require("nvim-treesitter")
      treesitter.setup(opts)
      local installed = treesitter.get_installed()
      vim.api.nvim_create_autocmd("FileType", {
        -- Use the list of installed parsers as the pattern
        pattern = installed,
        callback = function()
          vim.treesitter.start()
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      enable = true,
    },
    config = function(_, opts)
      vim.cmd([[hi TreesitterContext ctermfg=103 ctermbg=238 guifg=#8085a6 guibg=#32364c]])
      require('treesitter-context').setup(opts)
    end,
  },
}
