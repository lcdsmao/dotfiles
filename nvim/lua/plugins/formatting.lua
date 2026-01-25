return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          css = { "prettier" },
          html = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          lua = { "stylua" },
          sh = { "shfmt" },
          bash = { "shfmt" },
          zsh = { "shfmt" },
        },
        formatters = {
          prettier = {
            prepend_args = {
              "--trailing-comma", "es5",
              "--single-quote",
              "--no-semi",
            },
          },
          shfmt = {
            prepend_args = { "-i", "2", "-bn", "-ci", "-sr" },
          },
        },
      })

      -- Format function for keybindings
      local format = function()
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        })
      end

      -- Keybindings
      vim.keymap.set({ "n", "x" }, "=f", format, { desc = "Format buffer/selection" })

      -- :Format command
      vim.api.nvim_create_user_command("Format", format, { desc = "Format buffer" })
    end,
  },
}
