ktd() {
  local lint_scope=""
  local main_branch=""
  local target=""
  local response=""
  local tmp_file=""
  local -a ktlint_args
  local -a main_branch_candidates

  main_branch_candidates=(origin/main main origin/master master)

  if [ -n "$1" ] && git rev-parse --verify "$1^{commit}" >/dev/null 2>&1; then
    target="$1"
    shift
  fi

  ktlint_args=("$@")
  tmp_file="$(mktemp)"

  if [ -n "$target" ]; then
    lint_scope="Ktlint on Kotlin files changed since $target"
    git diff "$target...HEAD" --name-only -z --relative -- '*.kt' '*.kts' > "$tmp_file"
  elif git rev-parse --verify HEAD >/dev/null 2>&1; then
    lint_scope="Ktlint on uncommitted Kotlin files"
    {
      git diff HEAD --name-only -z --relative -- '*.kt' '*.kts'
      git ls-files --others --exclude-standard -z -- '*.kt' '*.kts'
    } > "$tmp_file"

    if [ ! -s "$tmp_file" ]; then
      for main_branch in "${main_branch_candidates[@]}"; do
        if git rev-parse --verify "$main_branch" >/dev/null 2>&1; then
          git diff "$main_branch...HEAD" --name-only -z --relative -- '*.kt' '*.kts' > "$tmp_file"
          if [ -s "$tmp_file" ]; then
            lint_scope="Ktlint on Kotlin files changed from merge-base with $main_branch"
            break
          fi
        fi
      done
    fi
  else
    lint_scope="Ktlint on uncommitted Kotlin files"
    git ls-files --others --exclude-standard -z -- '*.kt' '*.kts' > "$tmp_file"
  fi

  if [ ! -s "$tmp_file" ]; then
    rm -f "$tmp_file"
    echo "No Kotlin files to lint"
    return 0
  fi

  local ktlint_bin="${KTLINT:-ktlint}"

  echo "$("$ktlint_bin" --version)"
  echo "$lint_scope"

  if "$ktlint_bin" --relative "${ktlint_args[@]}" --patterns-from-stdin='' < "$tmp_file"; then
    rm -f "$tmp_file"
    return 0
  fi

  read "?Apply ktlint format? [y/N] " response
  case "$response" in
    [yY]|[yY][eE][sS])
      "$ktlint_bin" --relative -F "${ktlint_args[@]}" --patterns-from-stdin='' < "$tmp_file"
      ;;
  esac

  rm -f "$tmp_file"
}
