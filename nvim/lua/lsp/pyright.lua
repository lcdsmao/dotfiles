local function venv_python_path()
  local venv = vim.fs.find(".venv", { upward = true, type = "directory" })[1]
  if venv then
    local python = venv .. "/bin/python"
    if vim.uv.fs_stat(python) then
      return python
    end
  end
end

return {
  settings = {
    python = {
      pythonPath = venv_python_path(),
    },
  },
}
