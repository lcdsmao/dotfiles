function tmux-devl() {
  tmux split-window -h
  tmux split-window -v
  tmux select-pane -L
  tmux resize-pane -R 40
}
