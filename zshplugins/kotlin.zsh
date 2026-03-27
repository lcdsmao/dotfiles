ktd() {
  local target=""
  local response=""
  local tmp_file=""
  local -a ktlint_args

  if [ -n "$1" ] && git rev-parse --verify "$1^{commit}" >/dev/null 2>&1; then
    target="$1"
    shift
  fi

  ktlint_args=("$@")
  tmp_file="$(mktemp)"

  if [ -n "$target" ]; then
    git diff "$target...HEAD" --name-only -z --relative -- '*.kt' '*.kts' > "$tmp_file"
  elif git rev-parse --verify HEAD >/dev/null 2>&1; then
    {
      git diff HEAD --name-only -z --relative -- '*.kt' '*.kts'
      git ls-files --others --exclude-standard -z -- '*.kt' '*.kts'
    } > "$tmp_file"
  else
    git ls-files --others --exclude-standard -z -- '*.kt' '*.kts' > "$tmp_file"
  fi

  if [ ! -s "$tmp_file" ]; then
    rm -f "$tmp_file"
    echo "No Kotlin files to lint"
    return 0
  fi

  if ktlint --relative "${ktlint_args[@]}" --patterns-from-stdin='' < "$tmp_file"; then
    rm -f "$tmp_file"
    return 0
  fi

  read "?Apply ktlint format? [y/N] " response
  case "$response" in
    [yY]|[yY][eE][sS])
      ktlint --relative -F "${ktlint_args[@]}" --patterns-from-stdin='' < "$tmp_file"
      ;;
  esac

  rm -f "$tmp_file"
}
