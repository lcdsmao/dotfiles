return {
  -- Mason: LSP server installer
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
        },
      })
    end,
  },

  -- Mason-lspconfig: Bridge between mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        -- Auto-install these servers
        ensure_installed = {
          "rust_analyzer", -- Rust
          "jsonls",        -- JSON
          "lemminx",       -- XML
          "emmet_ls",      -- Emmet
          "bashls",        -- Bash/Shell
          "lua_ls",        -- Lua
          "ts_ls",         -- TypeScript/JavaScript
          "pyright",       -- Python
          "copilot",
        },
        -- Automatically enable installed servers (new API)
        automatic_enable = true,
      })
    end,
  },

  -- LSPconfig: Configure LSP servers
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "folke/lazydev.nvim",
      "saghen/blink.cmp",
      "nvimdev/lspsaga.nvim",
    },
    config = function()
      -- LSP capabilities (for blink.cmp)
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Setup lspsaga first (minimal config)
      require("lspsaga").setup({
        ui = {
          border = "rounded",
        },
        symbol_in_winbar = { enable = false },
        lightbulb = { enable = false },
        diagnostic = {
          diagnostic_only_current = true,
        },
      })

      -- Diagnostic configuration
      vim.diagnostic.config({
        update_in_insert = true,
        signs = {
          text = {
            -- [vim.diagnostic.severity.ERROR] = "",
            -- [vim.diagnostic.severity.WARN] = "",
            -- [vim.diagnostic.severity.INFO] = "",
            -- [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
          },
          numhl = {
            [vim.diagnostic.severity.ERROR] = "ErrorMsg",
            [vim.diagnostic.severity.WARN] = "WarningMsg",
            [vim.diagnostic.severity.INFO] = "InfoMsg",
            [vim.diagnostic.severity.HINT] = "HintMsg",
          }
        },
      })

      -- LSP keybindings - setup on LspAttach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          -- Disable semantic tokens to keep treesitter highlighting
          if client and client.server_capabilities then
            client.server_capabilities.semanticTokensProvider = nil
          end

          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
          end

          -- Navigation
          map("n", "gd", "<cmd>Telescope lsp_definitions<cr>", "Go to definition")
          map("n", "gy", "<cmd>Telescope lsp_type_definitions<cr>", "Go to type definition")
          map("n", "gi", "<cmd>Telescope lsp_implementations<cr>", "Go to implementation")
          map("n", "gr", "<cmd>Telescope lsp_references<cr>", "Find references")

          -- Symbols
          map("n", ",o", "<cmd>Telescope lsp_document_symbols<cr>", "Document symbols")
          map("n", ",s", "<cmd>Telescope lsp_workspace_symbols<cr>", "Workspace symbols")

          -- Documentation
          map("n", "K", "<cmd>Lspsaga hover_doc<cr>", "Show documentation")

          -- Diagnostics
          map("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<cr>", "Previous diagnostic")
          map("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<cr>", "Next diagnostic")
          map("n", ",d",
            "<cmd>lua require('telescope.builtin').diagnostics({wrap_results=true, line_width='full', bufnr=0})<cr>",
            "List diagnostics")

          -- Code actions
          map("n", ",rr", "<cmd>Lspsaga rename<cr>", "Rename symbol")
          map({ "n", "x" }, ",a", "<cmd>Lspsaga code_action<cr>", "Code action")
        end,
      })

      -- Default config for all servers
      vim.lsp.config('*', {
        capabilities = capabilities,
      })

      -- JSON-specific config
      vim.lsp.config.jsonls = {
        capabilities = capabilities,
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      }

      -- Emmet-specific config
      vim.lsp.config.emmet_ls = {
        capabilities = capabilities,
        filetypes = {
          "html",
          "css",
          "javascriptreact",
          "typescriptreact",
          "vue",
        },
      }

      -- SourceKit (Swift/iOS)
      vim.lsp.config.sourcekit = {
        capabilities = capabilities,
      }
      vim.lsp.enable("sourcekit")

      -- Pyright (Python) config
      local function venv_python_path()
        local venv = vim.fs.find(".venv", { upward = true, type = "directory" })[1]
        if venv then
          local python = venv .. "/bin/python"
          if vim.uv.fs_stat(python) then
            return python
          end
        end
      end

      vim.lsp.config.pyright = {
        capabilities = capabilities,
        settings = {
          python = {
            pythonPath = venv_python_path(),
          }
        }
      }
      vim.lsp.enable("pyright")

      -- Lua config
      vim.lsp.config.lua_ls = {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      }
    end,
  },

  -- blink.cmp: Completion engine
  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "fang2hou/blink-copilot",
    },
    version = "1.*",
    opts = {
      -- Custom keymap: Use Enter to accept completion
      keymap = {
        ['<CR>'] = { 'accept', 'fallback' },
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
      },

      -- Completion behavior
      completion = {
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },

      -- Sources
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer", "copilot" },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            async = true,
          },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },

      -- Use Rust fuzzy matcher for better performance
      fuzzy = { implementation = "prefer_rust_with_warning" },

      -- Integrate with vim-snippets (honza/vim-snippets)
      snippets = {
        preset = "default",
      },

      -- Cmdline completion
      cmdline = {
        keymap = {
          ['<CR>'] = { 'accept', 'fallback' },
        },
      },
    },
    opts_extend = { "sources.default" },
    config = function(_, opts)
      require("blink.cmp").setup(opts)

      -- Custom highlight for completion menu using dogrun colors
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.api.nvim_set_hl(0, "BlinkCmpMenu", { fg = "#9ea3c0", bg = "#32364c" })
          vim.api.nvim_set_hl(0, "BlinkCmpDoc", { fg = "#9ea3c0", bg = "#32364c" })
          vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { fg = "#8085a6", bg = "#32364c" })
        end,
      })

      -- Trigger immediately for current colorscheme
      vim.cmd("doautocmd ColorScheme")
    end,
  },

  -- JSON schemas for jsonls
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },

  -- Lazydev: LuaLS workspace library management
  {
    "folke/lazydev.nvim",
    ft = "lua",
    dependencies = {
      'DrKJeff16/wezterm-types',
    },
    opts = {
      library = {
        { path = 'wezterm-types', mods = { 'wezterm' } },
      },
    },
  },
}
