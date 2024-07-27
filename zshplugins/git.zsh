gitdb() {
  main_branch=$(git_main_branch)
  git branch --merged="$main_branch" | grep -v "$main_branch" | xargs git branch -d
  git fetch --prune
}

gitdsb() {
  main_branch=$(git_main_branch)
  branches=$(git checkout -q "$main_branch" && git for-each-ref refs/heads/ "--format=%(refname:short)")
  while read branch; do
    mergeBase=$(git merge-base "$main_branch" "$branch")
    if [[ $(git cherry "$main_branch" "$(git commit-tree "$(git rev-parse "$branch^{tree}")" -p "$mergeBase" -m _)") == "-"* ]]; then
      echo git branch -D "$branch"
    fi
  done <<< "$branches"
}
