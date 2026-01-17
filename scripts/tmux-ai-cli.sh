#!/usr/bin/env bash

# Get the current pane path
CURRENT_PATH="$1"

# Kill all other panes in the current window
tmux kill-pane -a

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create right pane with 50% width and run the AI CLI selector script
tmux split-window -h -l 50% -c "$CURRENT_PATH" "\"$SCRIPT_DIR/tmux-ai-cli-selector.sh\""
