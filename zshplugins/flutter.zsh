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

fv() {
  local p
  p=$(pwd)
  while [[ $p != / ]]; do
    if [[ -n "$(find "$p" -maxdepth 1 -mindepth 1 -iname '.fvm')" ]]; then
      "$p/.fvm/flutter_sdk/bin/flutter" "$@"
      return
    fi
    p="$(realpath "$p"/..)"
  done

  command flutter "$@"
}
