function! s:trigger_hot_reload() abort
    silent execute '!kill -SIGUSR1 "$(pgrep -f flutter_tools.snapshot\ run)" &> /dev/null'
endfunction

command! FlutterHotReload call s:trigger_hot_reload()

autocmd BufWritePost *.dart :FlutterHotReload

