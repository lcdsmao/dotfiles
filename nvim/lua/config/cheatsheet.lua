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

## Quickfix Operations (:cdo, :cfdo)
### Commands
- `:cdo cmd` - Execute cmd in each quickfix item's line
- `:cfdo cmd` - Execute cmd in each file in quickfix list
- `:ldo cmd` - Execute cmd in location list items
- `:lfdo cmd` - Execute cmd in location files

### Examples
```
:cdo s/old/new/ge       # Replace 'old' with 'new' across all matches
:cfdo %s/foo/bar/g      # Replace in each file that has matches
:cdo norm dd            # Delete matching lines from all files
:cfdo norm I//          # Comment out matching lines across files
:cdo s/^/# /            # Add prefix to all matching lines
:cfdo w                 # Save all modified files
```

## Substitution (:s)
### Basic Syntax
- `:s/old/new/` - Replace first match on current line
- `:s/old/new/g` - Replace all matches on current line
- `:%s/old/new/g` - Replace all in buffer
- `:5,10s/old/new/g` - Replace in range (lines 5-10)
- `:s/old/new/gc` - Replace with confirmation

### Quick Pattern Insertion (Ctrl+R)
In command mode, use Ctrl+R to insert:
- `<C-r><C-w>` - Insert word under cursor
- `<C-r><C-a>` - Insert WORD under cursor (including punctuation)
- `<C-r><C-f>` - Insert filename under cursor
- `<C-r><C-l>` - Insert entire line under cursor
- `<C-r>/` - Insert last search pattern
- `<C-r>"` - Insert last yanked text

### Examples
```
:s/foo/bar/           # Replace first 'foo' with 'bar' on line
:%s/foo/bar/g         # Replace all 'foo' with 'bar' in buffer
:%s/\<old\>/new/g     # Replace whole word 'old' with 'new'
:%s/^/# /g            # Add '# ' at start of every line
:%s/$/;/g             # Add ';' at end of every line
:cdo s/old/new/ge     # Replace in all quickfix items (e flag ignores errors)
```

## Global Command (:g)
### Syntax
- `:g/pattern/cmd` - Execute cmd on all lines matching pattern
- `:g!/pattern/cmd` - Execute cmd on non-matching lines
- `:g/pattern/` - Just list matching lines
- `:g/pattern/d` - Delete all matching lines
- `:g/pattern/m$` - Move matching lines to end of buffer
- `:g/pattern/t$` - Copy matching lines to end of buffer

### Examples
```
:g/TODO/print           # Print all lines containing TODO
:g/^$/d                 # Delete all empty lines
:g/function/norm I//    # Comment out all lines with 'function'
:g/error/t$             # Copy all error lines to end
:g!/^#/d                # Delete all non-comment lines
:g/pattern/,+2d         # Delete matching line + 2 lines after
```

## Normal Command (:norm)
### Syntax
- `:norm cmd` - Execute normal mode commands
- `:norm! cmd` - Execute without mapping
- `:%norm cmd` - Execute on every line in buffer
- `:5,10norm cmd` - Execute on range of lines

### Examples
```
:%norm A;               # Add ';' at end of every line
:%norm I//              # Add '//' at start of every line
:norm diw               # Delete current word on this line
:%norm >>               # Indent entire buffer
:g/pattern/norm dd      # Delete all matching lines
:cdo norm I//           # Comment matching lines (with quickfix)
:%norm gUU              # Convert to UPPERCASE
```

## Shell Command (:!)
### Syntax
- `:!command` - Execute shell command
- `:r!command` - Insert command output below cursor
- `:5r!command` - Insert command output after line 5
- `:%!command` - Filter buffer through command

### Examples
```
:!ls -la                # Run ls command
:r!date                 # Insert current date
:%!sort                 # Sort entire buffer
:%!uniq                 # Remove duplicate lines
:%!python3 -m json.tool # Format JSON
:%!sed 's/old/new/g'    # Filter with sed
:cdo !echo %            # Run command in each quickfix item
```

## Read & Replace Command (:r, .!)
### Syntax
- `:r file` - Read file below cursor
- `:r !command` - Read command output below cursor
- `:-1r file` - Read file above cursor
- `:0r file` - Read file at start of buffer
- `.!command` - Replace current line with command output

### Examples
```
:r ~/.config/template.txt    # Insert template file
:r !date                     # Insert current date
:0r !echo "# Header"         # Add header at start
:.!date                      # Replace current line with date
:.!echo "Generated"          # Replace with generated text
:5,.!sort                    # Sort lines 5 to current
:.!wc -l %                   # Replace with line count
```

### Key Difference
- `:r!cmd` - **Inserts** output below cursor (non-destructive)
- `:%!cmd` - **Filters** entire buffer through command
- `.!cmd` - **Replaces** current line with output

## Combined Patterns
### Bulk Editing Workflow
```
:g/TODO/cdo s/TODO/DONE/    # Replace TODO with DONE globally
:%norm I//                   # Comment all lines
:%!sort | uniq               # Sort and remove duplicates
:g/debug/d                   # Delete debug statements
:cdo norm dd                 # Delete all search results
```
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
