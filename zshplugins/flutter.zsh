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

flutter() {
  local search_path
  local flutter_path
  search_path=$(pwd)
  while [[ $search_path != / ]]; do
    flutter_path="$search_path/.fvm/flutter_sdk/bin/flutter"
    if [[ -f $flutter_path ]]; then
      if [[ -f melos.yaml ]]; then
        local package_path
        package_path=$(melos list -la | fzf | awk '{print $3}')
        (cd "$package_path" && $flutter_path "$@")
      else
        $flutter_path "$@"
      fi
      return
    fi
    search_path="$(realpath "$search_path"/..)"
  done

  command flutter "$@"
}
