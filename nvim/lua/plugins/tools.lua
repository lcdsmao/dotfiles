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
      require('telescope').load_extension('dap')

      vim.api.nvim_create_user_command("Dap", function()
        require("dapui").toggle()
      end, { bar = true })

      vim.api.nvim_create_user_command("DapFloat", function()
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        pickers.new({
          layout_config = {
            width = 60,
            height = 15,
          },
        }, {
          prompt_title = "Dapui Float",
          finder = finders.new_table({
            results = {
              "breakpoints",
              "console",
              "repl",
              "scopes",
              "stacks",
              "watches",
            },
          }),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr, map)
            local function float_element()
              local selection = action_state.get_selected_entry()
              if not selection then
                return
              end

              actions.close(prompt_bufnr)
              require("dapui").float_element(selection[1], {
                close_on_escape = true,
                position = "center",
                width = vim.o.columns - 20,
                height = vim.o.lines - 10,
              })
            end

            map("i", "<CR>", float_element)
            map("n", "<CR>", float_element)
            return true
          end,
        }):find()
      end, { bar = true })
    end,
  },
}
