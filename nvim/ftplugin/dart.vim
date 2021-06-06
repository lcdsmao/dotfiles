function! s:trigger_hot_reload() abort
    silent execute '!kill -SIGUSR1 "$(pgrep -f flutter_tools.snapshot\ run)" &> /dev/null'
endfunction

function! s:trigger_hot_restart() abort
    silent execute '!kill -SIGUSR2 "$(pgrep -f flutter_tools.snapshot\ run)" &> /dev/null'
endfunction

command! FlutterHotReload call s:trigger_hot_reload()
command! FlutterHotRestart call s:trigger_hot_restart()

nnoremap ,r :FlutterHotReload<CR>
