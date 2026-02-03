#!/bin/bash
PREFIX="_popup-"

# 1. Get all active window IDs (all sessions)
# We use a space-separated string for easier lookup in bash
active_windows=" $(tmux list-windows -a -F '#{window_id}' | tr '\n' ' ') "
# 2. Get all popup sessions
popup_sessions=$(tmux list-sessions -F '#S' | grep "^$PREFIX" || true)

# 3. Cleanup: Kill sessions tied to window IDs that no longer exist
if [ -n "$popup_sessions" ]; then
  while read -r sess; do
    [ -z "$sess" ] && continue
    # Extract the ID (e.g., @14)
    associated_id=${sess#"$PREFIX"}

    # Check if the ID exists in our active_windows string
    if [[ ! "$active_windows" =~ $associated_id ]]; then
      tmux kill-session -t "$sess" 2> /dev/null
    fi
  done <<< "$popup_sessions"
fi

# 4. Determine popup position based on current pane location
# Get the current pane's left position and the window width
pane_left=$(tmux display-message -p '#{pane_left}')
pane_width=$(tmux display-message -p '#{pane_width}')
window_width=$(tmux display-message -p '#{window_width}')

# Calculate if we're in the left or right half of the window
# If pane starts in the left half, position popup on the right
# If pane starts in the right half, position popup on the left
pane_center=$((pane_left + pane_width / 2))
window_center=$((window_width / 2))

if [ "$pane_center" -le "$window_center" ]; then
  # Current pane is on the left, show popup on the right
  # Calculate the starting column for the right half
  popup_x=$((window_width / 2 + 8))
else
  # Current pane is on the right, show popup on the left
  popup_x="8"
fi

# 5. Create/Attach the popup for the current window
current_id=$(tmux display-message -p '#{window_id}')
session_name="${PREFIX}${current_id}"

tmux display-popup -d "#{pane_current_path}" -E -w 45% -h 80% -x "$popup_x" -y C \
  "tmux new-session -A -s '$session_name' 'tmux set status off; \$SHELL'"
