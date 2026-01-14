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
    config = function()
      vim.cmd([[
        " Prompt for a command to run
        map <leader>vp :VimuxPromptCommand<CR>

        function! VimuxSlime()
          call VimuxRunCommand(trim(@v))
        endfunction

        " If text is selected, save it in the v buffer and send that buffer it to tmux
        vmap <leader>vs "vy :call VimuxSlime()<CR>h

        " Select current line and send it to tmux
        nmap <leader>vs V<leader>vs<CR>
      ]])
    end,
  },
  {
    "voldikss/vim-floaterm",
    lazy = false,
    init = function()
      -- These need to be set BEFORE the plugin loads
      vim.g.floaterm_width = 0.9
      vim.g.floaterm_height = 0.9
      vim.g.floaterm_keymap_toggle = '<C-Space><C-Space>'
      vim.g.floaterm_borderchars = '─│─│╭╮╯╰]'
    end,
    config = function()
      vim.cmd([[hi FloatermBorder guibg=#222433]])
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npx --yes yarn install",
    ft = "markdown",
  },
  {
    "rhysd/vim-grammarous",
  },
  {
    "mattn/emmet-vim",
  },
  {
    "github/copilot.vim",
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      file_types = { 'markdown', 'vimwiki' },
    },
  },
}
