" Plugs
call plug#begin('~/.vim_runtime/my_plugins')

Plug 'w0rp/ale'
Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}} " Coc intellisense engine

call plug#end()

" Basic
set number
set showcmd
set belloff=all
set clipboard+=unnamed
set encoding=utf-8

syntax on

filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

noremap ,a ^
noremap ,e $

map <leader>ss :split<cr>
map <leader>sv :vsplit<cr>


" autocompletion
set completeopt+=preview
set completeopt+=menuone
set completeopt+=noinsert
set shortmess+=c " turn off completion messages


" Ale
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['eslint'],
\}
let g:ale_linters = {
\   'rust': ['rls', 'cargo']
\}
let g:ale_lint_on_text_changed = 'never'

" use coc for jumps
nmap <leader>gd <Plug>(coc-definition)
nmap <leader>gr <Plug>(coc-references)

" Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" use <c-space> for trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" rename current word
nmap <leader>rr <Plug>(coc-rename)

" use <c-j> and <c-k> for selection options
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

"use <tab> for trigger completion, completion confirm, snippet expand and jump
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? coc#rpc#request('doKeymap', ['snippets-expand-jump','']) :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

let g:coc_snippet_next = '<tab>'
