#!/usr/bin/env bash

# Get the current pane path
CURRENT_PATH="${1:-$(tmux display-message -p '#{pane_current_path}')}"
CURRENT_WINDOW=$(tmux display-message -p '#{window_id}')
CURRENT_PANE=$(tmux display-message -p '#{pane_id}')

AI_PANE=""

# Find existing AI pane (by @pane-type) if any
while IFS=' ' read -r pane_id pane_type; do
  if [ "$pane_type" = "ai-cli" ]; then
    AI_PANE="$pane_id"
    break
  fi
done < <(tmux list-panes -t "$CURRENT_WINDOW" -F '#{pane_id} #{@pane-type}')

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create the AI pane when one does not already exist in this window.
if [ -z "$AI_PANE" ]; then
  # Determine the rightmost pane in this window and split it to create the AI pane
  RIGHTMOST_PANE=""
  max_right=-1
  while IFS=' ' read -r pid pane_right; do
    # pane_right is the column index of the pane's right edge
    if [ -n "$pane_right" ]; then
      if [ "$pane_right" -gt "$max_right" ]; then
        max_right="$pane_right"
        RIGHTMOST_PANE="$pid"
      fi
    fi
  done < <(tmux list-panes -t "$CURRENT_WINDOW" -F '#{pane_id} #{pane_right}')

  # Fallback to current pane if detection failed
  if [ -z "$RIGHTMOST_PANE" ]; then
    RIGHTMOST_PANE="$CURRENT_PANE"
  fi

  # Split the rightmost pane horizontally to place the new AI pane at the far right.
  # This only splits that single pane and does not move or join other panes, so
  # the overall layout of the other panes is preserved.
  AI_PANE=$(tmux split-window -h -t "$RIGHTMOST_PANE" -c "$CURRENT_PATH" -P -F '#{pane_id}' "$SCRIPT_DIR/tmux-ai-cli-selector.sh")

  # Mark the pane as the AI pane for the lifetime of the pane.
  tmux set-option -t "$AI_PANE" -p @pane-type "ai-cli"
fi

# Focus the AI pane if it exists (newly created or previously present)
if [ -n "$AI_PANE" ]; then
  tmux select-pane -t "$AI_PANE"
fi

# Open sidebar
tmux run-shell "\"#{@agent_sidebar_bin}\" toggle --create-only \"#{window_id}\" \"#{pane_current_path}\""
