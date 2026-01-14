local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Automatic toggling between line number modes
local number_toggle = augroup("NumberToggle", { clear = true })
autocmd({ "BufEnter", "FocusGained", "InsertLeave" }, {
  group = number_toggle,
  callback = function()
    if vim.bo.buftype == "" then
      vim.opt_local.relativenumber = true
    end
  end,
})
autocmd({ "BufLeave", "FocusLost", "InsertEnter" }, {
  group = number_toggle,
  callback = function()
    if vim.bo.buftype == "" then
      vim.opt_local.relativenumber = false
    end
  end,
})

-- Return to last edit position when opening files
autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
