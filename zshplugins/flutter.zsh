fhr() {
  local snapshot
  snapshot="$(pgrep -f flutter_tools.snapshot\ run)"
  if [[ -n $snapshot ]]; then
    if [[ $1 == '-f' ]]; then
      kill -SIGUSR2 "$snapshot" &> /dev/null
    else
      kill -SIGUSR1 "$snapshot" &> /dev/null
    fi
  fi
}
