-- Command typo fixes (compatible with blink.cmp cmdline)
local function command_with_bang(cmd)
  return function(opts)
    vim.cmd(cmd .. (opts.bang and "!" or ""))
  end
end

vim.api.nvim_create_user_command("W", command_with_bang("w"), { bang = true })
vim.api.nvim_create_user_command("Q", command_with_bang("q"), { bang = true })
vim.api.nvim_create_user_command("Qa", command_with_bang("qa"), { bang = true })
vim.api.nvim_create_user_command("Wa", command_with_bang("wa"), { bang = true })
vim.api.nvim_create_user_command("Wq", command_with_bang("wq"), { bang = true })
vim.api.nvim_create_user_command("WQ", command_with_bang("wq"), { bang = true })

-- Sudo save command
vim.api.nvim_create_user_command("Wsudo", "w !sudo tee % > /dev/null", {})

-- Insert date abbreviation
vim.cmd([[iab xdate <c-r>=strftime("%Y-%m-%d %H:%M:%S")<cr>]])

-- Redirect command output to scratch buffer
vim.api.nvim_create_user_command("Redir", function(ctx)
  local cmd = ctx.args
  local rng = ctx.range
  local start = ctx.line1
  local finish = ctx.line2

  -- Close existing scratch windows
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.w[win].scratch then
      vim.api.nvim_win_close(win, false)
    end
  end

  local output
  if vim.startswith(cmd, "!") then
    local shell_cmd = cmd:gsub("^!", "")
    if shell_cmd:find("%%") then
      shell_cmd = shell_cmd:gsub("%%", vim.fn.expand("%:p"))
    end

    if rng == 0 then
      output = vim.fn.systemlist(shell_cmd)
    else
      local lines = vim.api.nvim_buf_get_lines(0, start - 1, finish, false)
      local input = table.concat(lines, "\n")
      output = vim.fn.systemlist(shell_cmd .. " <<< " .. vim.fn.shellescape(input))
    end
  else
    output = vim.split(vim.api.nvim_exec2(cmd, { output = true }).output, "\n")
  end

  vim.cmd("vnew")
  vim.w.scratch = 1
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.buflisted = false
  vim.bo.swapfile = false
  vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
end, { nargs = 1, complete = "command", range = true })

-- Git quickfix commands
vim.api.nvim_create_user_command("Gshow", function(ctx)
  local files = vim.fn.systemlist("git show --pretty='' --name-only " .. ctx.args)
  local qflist = {}
  for _, file in ipairs(files) do
    table.insert(qflist, { filename = file, lnum = 1 })
  end
  vim.fn.setqflist(qflist)
  vim.cmd("copen")
end, { nargs = "?", bar = true })

vim.api.nvim_create_user_command("Gchanged", function()
  local files = vim.fn.systemlist("git ls-files -om --exclude-standard")
  local qflist = {}
  for _, file in ipairs(files) do
    table.insert(qflist, { filename = file, lnum = 1 })
  end
  vim.fn.setqflist(qflist)
  vim.cmd("copen")
end, { bar = true })
