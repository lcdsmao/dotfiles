return {
  {
    "christoomey/vim-tmux-navigator",
    config = function()
      vim.g.tmux_navigator_save_on_switch = 2
      vim.g.tmux_navigator_disable_when_zoomed = 1
    end,
  },
  {
    "benmills/vimux",
    init = function()
      vim.g.VimuxHeight = "50%"
      vim.g.VimuxOrientation = "h"
    end,
    keys = {
      { "<leader>vp", ":VimuxPromptCommand<CR>", desc = "Vimux prompt command" },
      {
        "<leader>vs",
        '"vy<cmd>lua require("vimux_slime").send(vim.fn.getreg("v"))<CR>',
        mode = "v",
        desc = "Send selection to tmux",
      },
      {
        "<leader>vs",
        function()
          require("vimux_slime").send(vim.fn.getline("."))
        end,
        mode = "n",
        desc = "Send line to tmux",
      },
    },
    config = function()
      local function is_ai_cli()
        if vim.fn.exists("g:VimuxRunnerIndex") == 0 then
          return false
        end

        local pane_type =
          vim.fn.system('tmux show-options -pv -t "' .. vim.g.VimuxRunnerIndex .. '" @pane-type 2>/dev/null')
        if vim.v.shell_error == 0 then
          pane_type = vim.fn.trim(pane_type)
          return pane_type == "ai-cli"
        end
        return false
      end

      package.loaded.vimux_slime = {
        send = function(text)
          local cmd = vim.fn.trim(text)

          if vim.fn.exists("g:VimuxRunnerIndex") == 0 then
            vim.fn.VimuxOpenRunner()
          end

          if is_ai_cli() then
            vim.fn.VimuxSendText("!" .. cmd)
            vim.defer_fn(function()
              vim.fn.VimuxSendKeys("Enter")
            end, 200)
          else
            vim.fn.VimuxRunCommand(cmd)
          end
        end,
      }
    end,
  },
}
