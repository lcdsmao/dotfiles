return {
  -- Prefer BSP (xcode-build-server) when available.
  -- This helps SourceKit-LSP keep an up-to-date index without requiring
  -- manual builds in Xcode/Xcodebuild.
  cmd = { "sourcekit-lsp", "--default-workspace-type", "buildServer" },
  -- Passed as `initializationOptions` to sourcekit-lsp.
  init_options = {
    -- Keep the index fresh by preparing targets in the background.
    backgroundIndexing = true,
    -- Avoid full builds when possible while still preparing for indexing.
    -- See: sourcekit-lsp Configuration File docs.
    backgroundPreparationMode = "enabled",
  },
}
