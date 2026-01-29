return {
  {
    "wojciech-kulik/xcodebuild.nvim",
    build = "make install",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      local progress_handle

      require("xcodebuild").setup({
        test_search = {
          lsp_client = "sourcekit",
        },
        integrations = {
          xcode_build_server = {
            enabled = true,
            guess_scheme = false,
          },
        },
        show_build_progress_bar = false,
        logs = {
          notify_progress = function(message)
            local progress = require("fidget.progress")

            if progress_handle then
              progress_handle.title = ""
              progress_handle.message = message
            else
              progress_handle = progress.handle.create({
                message = message,
                lsp_client = { name = "xcodebuild.nvim" },
              })
            end
          end,
        }
      })

      local augroup = vim.api.nvim_create_augroup("xcodebuild_keymaps", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = { "swift", "objc", "objcpp" },
        callback = function(event)
          vim.keymap.set("n", ",c", "<cmd>XcodebuildPicker<cr>",
            { desc = "Xcodebuild actions", silent = true, buffer = event.buf })
        end,
      })
    end,
  },
}
