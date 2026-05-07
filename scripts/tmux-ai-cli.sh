#!/usr/bin/env bash

# Get the current pane path
CURRENT_PATH="${1:-$(tmux display-message -p '#{pane_current_path}')}"
CURRENT_WINDOW=$(tmux display-message -p '#{window_id}')
CURRENT_PANE=$(tmux display-message -p '#{pane_id}')

AI_PANE=""
LEFT_PANES=()

while IFS=' ' read -r pane_id pane_type; do
  if [ "$pane_type" = "ai-cli" ]; then
    AI_PANE="$pane_id"
  else
    LEFT_PANES+=("$pane_id")
  fi
done < <(tmux list-panes -t "$CURRENT_WINDOW" -F '#{pane_id} #{@pane-type}')

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create the AI pane when one does not already exist in this window.
if [ -z "$AI_PANE" ]; then
  AI_PANE=$(tmux split-window -h -l 50% -c "$CURRENT_PATH" -P -F '#{pane_id}' "\"$SCRIPT_DIR/tmux-ai-cli-selector.sh\"")

  # Set a custom tmux user option on the newly created pane.
  # This persists for the lifetime of the pane and can't be changed by the CLI.
  tmux set-option -t "$AI_PANE" -p @pane-type "ai-cli"
fi

if [ ${#LEFT_PANES[@]} -eq 0 ]; then
  exit 0
fi

LEFT_TARGET="${LEFT_PANES[0]}"
if [ "$CURRENT_PANE" != "$AI_PANE" ]; then
  LEFT_TARGET="$CURRENT_PANE"
fi

# Keep the AI pane as the full-height pane on the right. Move every other pane
# into the left side as vertical splits, preserving running processes.
tmux join-pane -h -l 50% -s "$AI_PANE" -t "$LEFT_TARGET"

for pane_id in "${LEFT_PANES[@]}"; do
  if [ "$pane_id" != "$LEFT_TARGET" ]; then
    tmux join-pane -v -s "$pane_id" -t "$LEFT_TARGET"
  fi
done

tmux select-layout -t "$CURRENT_WINDOW" -E
tmux select-pane -t "$AI_PANE"

# Set a custom tmux user option on the AI pane.
# This persists for the lifetime of the pane and can't be changed by the CLI
tmux set-option -t "$AI_PANE" -p @pane-type "ai-cli"
