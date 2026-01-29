return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      local function filetype_fmt(name, context)
        local filetype = vim.o.filetype
        if filetype == 'fzf' then
          return 'fzf'
        elseif filetype == 'coc-explorer' then
          return 'coc-explorer'
        elseif filetype == 'floaterm' then
          return 'term'
        end
        return name
      end

      local function xcodebuild_device()
        if vim.g.xcodebuild_platform == "macOS" then
          return " macOS"
        end

        local deviceIcon = ""
        if vim.g.xcodebuild_os then
          return deviceIcon .. " " .. vim.g.xcodebuild_device_name .. " (" .. vim.g.xcodebuild_os .. ")"
        end

        return deviceIcon .. " " .. vim.g.xcodebuild_device_name
      end

      return {
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = '',
          section_separators = { left = '', right = '' },
          disabled_filetypes = {
            statusline = { 'coc-explorer', 'gitsigns-blame' },
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = false,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = {
            'branch',
            'diff',
          },
          lualine_c = {
            {
              'diagnostics',
              sources = { 'nvim_diagnostic', 'coc' },
              sections = { 'error', 'warn', 'info', 'hint' },
              diagnostics_color = {
                error = 'DiagnosticError',
                warn  = 'DiagnosticWarn',
                info  = 'DiagnosticInfo',
                hint  = 'DiagnosticHint',
              },
              symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
              colored = true,
              update_in_insert = false,
              always_visible = false,
            }
          },
          lualine_x = {
            'encoding',
            'fileformat',
            'filetype',
          },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        },
        tabline = {
          lualine_c = {
            {
              'filename',
              path = 1,
              shorting_target = 0,
              symbols = {
                modified = '[+]',
                readonly = '[-]',
                unnamed = '[No Name]',
                newfile = '[New]',
              },
              color = 'StatusLine',
              fmt = filetype_fmt
            }
          },
          lualine_x = {
            { "' ' .. vim.g.xcodebuild_last_status", color = { fg = "Gray" } },
            { "'󰙨 ' .. vim.g.xcodebuild_test_plan", color = { fg = "#a6e3a1" } },
            { xcodebuild_device, color = { fg = "#f9e2af" } },
          },
        },
        winbar = {},
        inactive_winbar = {},
        extensions = { 'neo-tree', 'quickfix' },
      }
    end,
  },
  {
    "j-hui/fidget.nvim",
    opts = {},
  },
  {
    "rcarriga/nvim-notify",
    config = function()
      vim.notify = require("notify")
    end,
  },
  {
    "wadackel/vim-dogrun",
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.termguicolors = true
      vim.cmd([[colorscheme dogrun]])
    end,
  },
}
