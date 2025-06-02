UsePlugin 'vim-tmux-navigator'
UsePlugin 'vimux'

" Write all buffers before navigating from Vim to tmux pane
let g:tmux_navigator_save_on_switch = 2
" Disable tmux navigator when zooming the Vim pane
let g:tmux_navigator_disable_when_zoomed = 1

" Prompt for a command to run
map <leader>vp :VimuxPromptCommand<CR>

function! VimuxSlime()
  call VimuxRunCommand(trim(@v))
endfunction

" If text is selected, save it in the v buffer and send that buffer it to tmux
vmap <leader>vs "vy :call VimuxSlime()<CR>h

" Select current line and send it to tmux
nmap <leader>vs V<leader>vs<CR>

