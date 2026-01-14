local M = {}

M.cheatsheet_content = [[
# My Cheatsheet

## Quickfix List (nvim-bqf)
### Basic Navigation
- `]q` - Next quickfix item (:cnext)
- `[q` - Previous quickfix item (:cprevious)
- `]Q` - Last quickfix item (:clast)
- `[Q` - First quickfix item (:cfirst)
- `:copen` - Open quickfix window
- `:cclose` - Close quickfix window
- `:clist` - List all quickfix items

### Opening Items
- `<CR>` - Open item under cursor
- `o` - Open item and close quickfix
- `O` - Drop to open item and close quickfix

### Preview
- `p` - Toggle preview for current item
- `P` - Toggle auto-preview
- `<C-b>` - Scroll preview up half page
- `<C-f>` - Scroll preview down half page
- `zo` - Scroll back to original position
- `zp` - Toggle preview max/normal size

### Navigation & History
- `<C-p>` - Go to previous file
- `<C-n>` - Go to next file
- `<` - Cycle to previous qf list
- `>` - Cycle to next qf list
- `'"` - Go to last selected item

### Filtering with Signs
- `<Tab>` - Toggle sign and move down
- `<S-Tab>` - Toggle sign and move up
- `<Tab>` (visual) - Toggle multiple signs
- `'<Tab>` - Toggle signs for same buffer
- `z<Tab>` - Clear all signs
- `zn` - Create new list with signed items
- `zN` - Create new list without signed items
]]

function M.show_cheatsheet()
  -- Create a new buffer
  local buf = vim.api.nvim_create_buf(false, true)

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)

  -- Split content into lines
  local lines = vim.split(M.cheatsheet_content, '\n')

  -- Set buffer content
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)

  -- Set buffer name
  vim.api.nvim_buf_set_name(buf, 'Cheatsheet')

  -- Open in vertical split
  vim.cmd('vnew')
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)

  -- Set window options
  vim.api.nvim_win_set_option(win, 'wrap', false)

  -- Set buffer-local keymaps to close
  local opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set('n', 'q', ':close<CR>', opts)
  vim.keymap.set('n', '<Esc>', ':close<CR>', opts)
end

-- Create command
vim.api.nvim_create_user_command('Cheatsheet', M.show_cheatsheet, {})

return M
