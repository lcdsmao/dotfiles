#!/usr/bin/env bash

# Get the current pane path
CURRENT_PATH="$1"

# Kill all other panes in the current window
tmux kill-pane -a

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create right pane with 50% width and run the AI CLI selector script
tmux split-window -h -l 50% -c "$CURRENT_PATH" "\"$SCRIPT_DIR/tmux-ai-cli-selector.sh\""

# Set a custom tmux user option on the newly created pane (which is now active)
# This persists for the lifetime of the pane and can't be changed by the CLI
tmux set-option -p @pane-type "ai-cli"
