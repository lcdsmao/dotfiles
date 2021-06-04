tmux-devl() {
  tmux split-window -h
  tmux select-layout main-vertical
  tmux select-pane -L
  tmux split-window -v
  tmux select-pane -R
}
