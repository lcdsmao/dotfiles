return {
  {
    "wojciech-kulik/xcodebuild.nvim",
    build = "make install",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
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
      })

      local augroup = vim.api.nvim_create_augroup("xcodebuild_keymaps", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = { "swift", "objc", "objcpp" },
        callback = function(event)
          vim.keymap.set( "n", ",c", "<cmd>XcodebuildPicker<cr>", { desc = "Xcodebuild actions", silent = true, buffer = event.buf })
        end,
      })
    end,
  },
}
