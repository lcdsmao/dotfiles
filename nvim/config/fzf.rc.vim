UsePlugin 'fzf'
UsePlugin 'fzf.vim'

nmap <leader>ff :Files<cr>
nmap <leader>fa :AFiles<cr>
nmap <leader>fg :GFiles<cr>
nmap <leader>fs :GFiles?<cr>
nmap <leader>fb :Buffers<cr>
nmap <leader>fr :RG<cr>
nmap <leader>fh :History<cr>
nmap <leader>fw viwy:Rg <c-r>"<cr>
xmap <leader>fw y:Rg <c-r>"<cr>

function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let g:fzf_action = {
      \ 'ctrl-q': function('s:build_quickfix_list'),
      \ 'ctrl-t': 'tab split',
      \ 'ctrl-x': 'split',
      \ 'ctrl-v': 'vsplit' }

" You can set up fzf window using a Vim command (Neovim or latest Vim 8 required)
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.7, 'highlight': 'Comment' } }
let g:fzf_preview_window = ['up:40%']
