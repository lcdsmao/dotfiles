gitD2w() {
  for k in $(git branch --format="%(refname:short)"); do
    if (($(git log -1 --since='2 week ago' -s "$k" | wc -l) == 0)); then
      echo git branch -D "$k"
    fi
  done
}

gitdb() {
  local main_branch
  main_branch=$(git_main_branch)
  git branch --merged="$main_branch" | grep -v "$main_branch" | xargs git branch -d
  git fetch --prune
}
