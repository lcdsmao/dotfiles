ktd() {
  git diff "$1" --name-only -z --cached --relative -- '*.kt' '*.kts' | ktlint --relative "$2" --patterns-from-stdin=''
}
