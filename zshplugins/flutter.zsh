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
    [[ -f $flutter_path ]] && break
    search_path="$(realpath "$search_path"/..)"
  done

  local check_melos
  case "$1" in
    analyze | assemble | build | clean | drive | gen-l10n | pub | run | test)
      check_melos='true'
      ;;
  esac

  local package_path
  if [[ $check_melos == 'true' && -f melos.yaml ]]; then
    package_path=$(melos list -la | fzf | awk '{print $3}')
  fi

  (
    # shellcheck disable=SC2164
    [[ -d $package_path ]] && cd "$package_path"
    if [[ -f $flutter_path ]]; then
      $flutter_path "$@"
    else
      command flutter "$@"
    fi
  )
}
