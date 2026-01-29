return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      file_types = { "markdown", "vimwiki" },
      preset = "lazy",
      anti_conceal = {
        enabled = false,
      },
      ignore = function(bufnr)
        -- Ignore nofile buffers or name is empty
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
        local name = vim.api.nvim_buf_get_name(bufnr)
        return buftype == "nofile" or name == ""
      end,
    },
  },
  {
    "rhysd/vim-grammarous",
  },
  {
    "mattn/emmet-vim",
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-dap.nvim",
    },
    config = function()
      require("dapui").setup({})

      vim.api.nvim_create_user_command("Dap", function()
        require("dapui").toggle()
      end, { bar = true })

      require('telescope').load_extension('dap')
    end,
  },
}
