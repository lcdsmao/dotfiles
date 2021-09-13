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

let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'

" You can set up fzf window using a Vim command (Neovim or latest Vim 8 required)
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.7, 'highlight': 'Comment' } }
let g:fzf_preview_window = ['up:40%']

" Similarly, we can apply it to fzf#vim#grep. To use ripgrep instead of ag:
" command! -bang -nargs=* Rg
"             \ call fzf#vim#grep(
"             \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
"             \   <bang>0 ? fzf#vim#with_preview('up:60%')
"             \           : fzf#vim#with_preview('right:50%:hidden', '?'),
"             \   <bang>0)
command! -bang -nargs=* Rg
      \ call fzf#vim#grep(
      \   'rg --column --line-number --no-heading --color=always --smart-case --hidden --glob "!**/.git/**" -- '.shellescape(<q-args>), 1,
      \   fzf#vim#with_preview(), <bang>0)

" Make fzf completely delegate its search responsibliity to ripgrep. 
" Process by making it restart ripgrep whenever the query string is updated.
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case --hidden --glob "!**/.git/**" -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

" Likewise, Files command with preview window
command! -bang -nargs=? -complete=dir Files 
      \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=? -complete=dir AFiles
      \ call fzf#vim#files(<q-args>, 
      \ extend({'source': 'fd --type f --hidden --no-ignore --follow --exclude .git ""'},
      \ fzf#vim#with_preview()), <bang>0)

command! -bang -nargs=? -complete=dir GFiles
      \ call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview(), <bang>0)
