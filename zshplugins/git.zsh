gitdb() {
  main_branch=$(git_main_branch)
  git branch --merged="$main_branch" | grep -v "$main_branch" | xargs git branch -d
  git fetch --prune
}

gitdsb() {
  target_branch="${1:-$(git_main_branch)}"
  branches=$(git checkout -q "$target_branch" && git for-each-ref refs/heads/ "--format=%(refname:short)")
  while read -r branch; do
    mergeBase=$(git merge-base "$target_branch" "$branch")
    if [[ -n $mergeBase && $(git cherry "$target_branch" "$(git commit-tree "$(git rev-parse "$branch^{tree}")" -p "$mergeBase" -m _)") == "-"* ]]; then
      echo git branch -D "$branch"
    fi
  done <<< "$branches"
}
