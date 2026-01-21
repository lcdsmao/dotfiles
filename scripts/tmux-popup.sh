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

# 4. Create/Attach the popup for the current window
current_id=$(tmux display-message -p '#{window_id}')
session_name="${PREFIX}${current_id}"

tmux display-popup -d "#{pane_current_path}" -E -w 80% -h 80% \
    "tmux new-session -A -s '$session_name' 'tmux set status off; \$SHELL'"
