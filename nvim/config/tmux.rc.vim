UsePlugin 'vim-tmux-navigator'
UsePlugin 'vimux'

" Write all buffers before navigating from Vim to tmux pane
let g:tmux_navigator_save_on_switch = 2
" Disable tmux navigator when zooming the Vim pane
let g:tmux_navigator_disable_when_zoomed = 1

" Prompt for a command to run
map <leader>vp :VimuxPromptCommand<CR>
