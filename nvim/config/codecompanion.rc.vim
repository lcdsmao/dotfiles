UsePlugin 'codecompanion.nvim'

lua << EOF
require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = "copilot",
      opts = {
        completion_provider = "coc", -- blink|cmp|coc|default
      }
    },
    inline = {
      adapter = "copilot",
    },
  },
  display = {
    action_palette = {
      provider = "telescope",
    },
    chat = {
      intro_message = "Welcome to CodeCompanion ✨\n\nYou can use variables, slash commands, and tools to enhance your experience:\n- Variables: #{buffer}, #{lsp}, #{viewport}\n- Slash commands: /buffer, /file, /help, /now, /symbols, /terminal\n- Tools: @cmd_runner, @files, @web_search\n\nPress ? for more help",
    },
  },
  opts = {
    log_level = "DEBUG",
    send_code = true,
  },
  tools = {
    enabled = {
      "cmd_runner",
      "create_file", 
      "file_search",
      "get_changed_files",
      "grep_search",
      "insert_edit_into_file",
      "next_edit_suggestion",
      "read_file",
      "web_search",
    },
  },
})

-- Key mappings for codecompanion
vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true, desc = "Open CodeCompanion Action Palette" })
vim.keymap.set({ "n", "v" }, "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true, desc = "Toggle CodeCompanion Chat" })
vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true, desc = "Add selection to chat" })
vim.keymap.set("n", "<LocalLeader>cc", "<cmd>CodeCompanionChat<cr>", { noremap = true, silent = true, desc = "Open CodeCompanion Chat" })
vim.keymap.set("n", "<LocalLeader>ci", "<cmd>CodeCompanion<cr>", { noremap = true, silent = true, desc = "Inline CodeCompanion" })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])
EOF
