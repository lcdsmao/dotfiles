set clipboard+=unnamed

let mapleader = " "

noremap <leader>a ^
noremap <leader>e $

" Split
noremap <leader>ss :split<cr>
noremap <leader>sv :vsplit<cr>

" Paste
nmap <c-p> :pu<CR>

" Yank a region in VIM without the cursor moving to the top of the block
vmap y ygv<ESC>

" Fast saving
nmap <leader>w :w!<cr>

" Always show current position
set ruler

" When searching try to be smart about cases 
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch 

" Don't redraw while executing macros (good performance config)
set lazyredraw 

" For regular expressions turn magic on
set magic

" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 2 spaces
set shiftwidth=2
set tabstop=2

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

" Move half
nnoremap <leader>k <c-u>
nnoremap <leader>j <c-d>

"*****************************************************************************
"" Abbreviations
"*****************************************************************************
"" no one is really happy until you have this shortcuts
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qa! qa!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qa qa
