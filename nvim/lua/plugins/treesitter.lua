return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- Install parsers
      require('nvim-treesitter').install({
        "markdown",
        "markdown_inline",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "javascript",
        "typescript",
        "python",
        "rust",
        "go",
        "java",
        "c",
        "cpp",
        "bash",
        "git_config",
        "git_rebase",
        "gitcommit",
        "gitignore",
        "diff",
      })

      -- Enable treesitter features for all installed parsers
      vim.api.nvim_create_autocmd('FileType', {
        pattern = '*',
        callback = function()
          local ok, _ = pcall(vim.treesitter.start)
          if ok then
            -- Enable treesitter-based indentation
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      enable = true,
    },
    config = function(_, opts)
      vim.cmd([[hi TreesitterContext ctermfg=103 ctermbg=238 guifg=#8085a6 guibg=#32364c]])
      require('treesitter-context').setup(opts)
    end,
  },
}
