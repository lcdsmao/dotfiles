-- Basic options
local opt = vim.opt

opt.showcmd = true
opt.clipboard:append("unnamed")
opt.autoread = true

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Performance
opt.lazyredraw = true

-- Regex
opt.magic = true

-- Matching brackets
opt.showmatch = true
opt.mat = 2

-- Errors
opt.errorbells = false
opt.visualbell = false
opt.tm = 500

-- UI
opt.foldcolumn = "1"
opt.ruler = true
opt.wildmenu = true
opt.wildignore = { "*.o", "*~", "*.pyc", "*/.git/*", "*/.hg/*", "*/.svn/*", "*/.DS_Store" }

-- Encoding
opt.encoding = "utf8"
opt.fileformats = { "unix", "dos", "mac" }

-- Backup
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Tabs & Indentation
opt.expandtab = true
opt.smarttab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.autoindent = true
opt.smartindent = true
opt.wrap = true
opt.linebreak = true
opt.textwidth = 500

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Status line
opt.showtabline = 2

-- Persistent undo
local undodir = vim.fn.stdpath("config") .. "/temp_dirs/undodir"
vim.fn.mkdir(undodir, "p")
opt.undodir = undodir
opt.undofile = true

-- GUI options (if applicable)
if vim.fn.has("gui_running") == 1 then
  opt.guioptions:remove("r")
  opt.guioptions:remove("R")
  opt.guioptions:remove("l")
  opt.guioptions:remove("L")
  
  if vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1 then
    opt.guifont = "IBM Plex Mono:h14,Hack:h14,Source Code Pro:h15,Menlo:h15"
  elseif vim.fn.has("win32") == 1 then
    opt.guifont = "IBM Plex Mono:h14,Source Code Pro:h12,Bitstream Vera Sans Mono:h11"
  elseif vim.fn.has("linux") == 1 then
    opt.guifont = "IBM Plex Mono:h14,Hack 14,Source Code Pro 12,Bitstream Vera Sans Mono 11"
  end
end

-- Terminal colors
if vim.env.COLORTERM == "gnome-terminal" then
  opt.t_Co = 256
end
