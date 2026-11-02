local rbenv = vim.fn.exepath("rbenv")

if rbenv == "" then
  rbenv = "rbenv"
end

return {
  -- Use the Ruby selected by the project's .ruby-version or rbenv default.
  cmd = { rbenv, "exec", "ruby-lsp" },
}
