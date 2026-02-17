#!/usr/bin/env bash
PREFIX="_popup-"

# Convert a pane path into a session-safe key.
# Keep a readable prefix + short hash to avoid collisions.
path_to_key() {
	local raw_path="$1"
	local safe
	local hash

	# tmux session names normalize some punctuation (for example '.' -> '_').
	# Keep only characters that round-trip reliably in session names.
	safe=$(printf '%s' "$raw_path" | tr -c '[:alnum:]_-' '_')
	safe=${safe#_}
	safe=${safe%_}
	[ -z "$safe" ] && safe="pane"
	safe=${safe:0:24}

	hash=$(printf '%s' "$raw_path" | shasum | cut -c1-10)
	printf '%s_%s' "$safe" "$hash"
}

# 1. Resolve current pane path/key first.
current_path=$(tmux display-message -p '#{pane_current_path}')
session_key=$(path_to_key "$current_path")
session_name="${PREFIX}${session_key}"

# 2. Get all active pane-path keys from non-popup sessions
# We use a space-separated string for easier lookup in bash.
# Seed with current key to avoid accidental cleanup mismatch.
active_keys=" ${session_key} "
while IFS=$'\t' read -r pane_session pane_path; do
	[ -z "$pane_path" ] && continue
	case "$pane_session" in
	"${PREFIX}"*) continue ;;
	esac
	key=$(path_to_key "$pane_path")
	active_keys+="${key} "
done < <(tmux list-panes -a -F '#{session_name}\t#{pane_current_path}')

# 3. Get all popup sessions
popup_sessions=$(tmux list-sessions -F '#S' | grep "^$PREFIX" || true)

# 4. Cleanup: Kill sessions tied to pane paths that no longer exist
if [ -n "$popup_sessions" ]; then
	while read -r sess; do
		[ -z "$sess" ] && continue

		# Never kill the session we are about to open/attach.
		if [ "$sess" = "$session_name" ]; then
			continue
		fi

		associated_key=${sess#"$PREFIX"}

		# Check if the key exists in our active_keys string
		if [[ "$active_keys" != *" ${associated_key} "* ]]; then
			tmux kill-session -t "$sess" 2>/dev/null
		fi
	done <<<"$popup_sessions"
fi

# 5. Determine popup position based on current pane location
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

# 6. Create/Attach the popup for the current pane path
tmux display-popup -d "#{pane_current_path}" -E -w 45% -h 80% -x "$popup_x" -y C \
	"tmux new-session -A -s '$session_name' 'tmux set status off; \$SHELL'"
