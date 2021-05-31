fhr() {
  local snapshot
  snapshot="$(pgrep -f flutter_tools.snapshot\ run)"
  if [[ -n $snapshot ]]; then
    kill -SIGUSR1 "$snapshot" &> /dev/null
  fi
}
