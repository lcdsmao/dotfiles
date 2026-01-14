-- Command abbreviations for typos
vim.cmd([[
  cnoreabbrev W! w!
  cnoreabbrev Q! q!
  cnoreabbrev Qall! qall!
  cnoreabbrev Wq wq
  cnoreabbrev Wa wa
  cnoreabbrev wQ wq
  cnoreabbrev WQ wq
  cnoreabbrev W w
  cnoreabbrev Q q
  cnoreabbrev Qall qall
]])

-- Sudo save command
vim.api.nvim_create_user_command("W", "w !sudo tee % > /dev/null", {})

-- Insert date abbreviation
vim.cmd([[iab xdate <c-r>=strftime("%d/%m/%y %H:%M:%S")<cr>]])

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

-- Bclose command - Delete buffer while keeping window layout
vim.g.bclose_multiple = 1

local function warn(msg)
  vim.api.nvim_echo({ { msg, "ErrorMsg" } }, true, {})
end

local function bclose(bang, buffer)
  local btarget
  if buffer == "" then
    btarget = vim.fn.bufnr("%")
  elseif buffer:match("^%d+$") then
    btarget = tonumber(buffer)
  else
    btarget = vim.fn.bufnr(buffer)
  end

  if btarget < 0 then
    warn("No matching buffer for " .. buffer)
    return
  end

  if bang == "" and vim.fn.getbufvar(btarget, "&modified") == 1 then
    warn("No write since last change for buffer " .. btarget .. " (use :Bclose!)")
    return
  end

  -- Get windows showing target buffer
  local wnums = {}
  for w = 1, vim.fn.winnr("$") do
    if vim.fn.winbufnr(w) == btarget then
      table.insert(wnums, w)
    end
  end

  if vim.g.bclose_multiple ~= 1 and #wnums > 1 then
    warn('Buffer is in multiple windows (use ":let bclose_multiple=1")')
    return
  end

  local wcurrent = vim.fn.winnr()
  for _, w in ipairs(wnums) do
    vim.cmd(w .. "wincmd w")
    local prevbuf = vim.fn.bufnr("#")
    if prevbuf > 0 and vim.fn.buflisted(prevbuf) == 1 and prevbuf ~= btarget then
      vim.cmd("buffer #")
    else
      vim.cmd("bprevious")
    end

    if btarget == vim.fn.bufnr("%") then
      local blisted = {}
      for b = 1, vim.fn.bufnr("$") do
        if vim.fn.buflisted(b) == 1 and b ~= btarget then
          table.insert(blisted, b)
        end
      end

      local bhidden = {}
      for _, b in ipairs(blisted) do
        if vim.fn.bufwinnr(b) < 0 then
          table.insert(bhidden, b)
        end
      end

      local bjump = (bhidden[1] or blisted[1]) or -1
      if bjump > 0 then
        vim.cmd("buffer " .. bjump)
      else
        vim.cmd("enew" .. bang)
      end
    end
  end

  vim.cmd("bdelete" .. bang .. " " .. btarget)
  vim.cmd(wcurrent .. "wincmd w")
end

vim.api.nvim_create_user_command("Bclose", function(ctx)
  bclose(ctx.bang and "!" or "", ctx.args)
end, { bang = true, nargs = "?", complete = "buffer" })

vim.keymap.set("n", "<leader>x", ":Bclose<CR>", { desc = "Close buffer" })

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
