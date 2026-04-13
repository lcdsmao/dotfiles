return {
  {
    "AlexandrosAlexiou/kotlin.nvim",
    ft = { "kotlin" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("kotlin").setup({
        root_markers = {
          "gradlew",
          ".git",
          "mvnw",
          "settings.gradle",
        },
        inlay_hints = {
          enabled = false,
        },
      })
    end,
  },
}
