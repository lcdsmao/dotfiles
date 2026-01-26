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
      })

      -- Diagnostic configuration
      vim.diagnostic.config({
        update_in_insert = true,
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

          -- Navigation with Telescope
          map("n", "gd", "<cmd>Telescope lsp_definitions<cr>", "Go to definition")
          map("n", "gy", "<cmd>Telescope lsp_type_definitions<cr>", "Go to type definition")
          map("n", "gi", "<cmd>Telescope lsp_implementations<cr>", "Go to implementation")
          map("n", "gr", "<cmd>Telescope lsp_references<cr>", "Find references")

          -- Documentation (lspsaga)
          map("n", "K", "<cmd>Lspsaga hover_doc<cr>", "Show documentation")

          -- Diagnostics (lspsaga)
          map("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<cr>", "Previous diagnostic")
          map("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<cr>", "Next diagnostic")

          -- Code actions (lspsaga)
          map("n", "<leader>rr", "<cmd>Lspsaga rename<cr>", "Rename symbol")
          map({ "n", "x" }, ",a", "<cmd>Lspsaga code_action<cr>", "Code action")
          map("n", ",qf", "<cmd>Lspsaga code_action<cr>", "Quick fix")

          -- Lists with Telescope
          map("n", ",d", "<cmd>Telescope diagnostics<cr>", "List diagnostics")
          map("n", ",o", "<cmd>Telescope lsp_document_symbols<cr>", "Document symbols")
          map("n", ",s", "<cmd>Telescope lsp_workspace_symbols<cr>", "Workspace symbols")
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
        default = { "lsp", "path", "snippets", "buffer", "copilot" },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            async = true,
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
}
