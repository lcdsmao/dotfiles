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
        }, function(err, did_set)
          -- Notify if error occurs
          if err then
            vim.notify(err or "Formatted successfully", vim.log.levels.ERROR, { title = "Conform" })
          end
        end)
      end

      -- Keybindings
      vim.keymap.set({ "n", "x" }, ",f", format, { desc = "Format buffer/selection" })

      -- :Format command
      vim.api.nvim_create_user_command("Format", format, { desc = "Format buffer" })
    end,
  },
}
