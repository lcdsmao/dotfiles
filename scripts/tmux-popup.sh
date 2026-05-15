#!/usr/bin/env bash
set -e

POPUP_SESSION="popup"

configure_popup_session() {
	tmux set-option -t "$POPUP_SESSION" status-right '' >/dev/null
}

find_window_for_path() {
	local path="$1"
	local window_id
	local window_path

	while read -r window_id; do
		window_path=$(tmux show-window-option -v -t "$window_id" @popup_path 2>/dev/null || true)
		if [ "$window_path" = "$path" ]; then
			printf '%s' "$window_id"
			return 0
		fi
	done < <(tmux list-windows -t "$POPUP_SESSION" -F '#{window_id}')

	return 1
}

current_path=${1:-$(tmux display-message -p '#{pane_current_path}')}

if ! tmux has-session -t "$POPUP_SESSION" 2>/dev/null; then
	window_id=$(tmux new-session -d -P -F '#{window_id}' -s "$POPUP_SESSION" -c "$current_path" "exec \"${SHELL:-/bin/sh}\"")
	tmux set-window-option -t "$window_id" @popup_path "$current_path" >/dev/null
	configure_popup_session
else
	configure_popup_session
	if ! window_id=$(find_window_for_path "$current_path"); then
		window_id=$(tmux new-window -d -P -F '#{window_id}' -t "$POPUP_SESSION:" -c "$current_path" "exec \"${SHELL:-/bin/sh}\"")
		tmux set-window-option -t "$window_id" @popup_path "$current_path" >/dev/null
	fi
fi

tmux select-window -t "$window_id"

pane_left=${2:-$(tmux display-message -p '#{pane_left}')}
pane_width=${3:-$(tmux display-message -p '#{pane_width}')}
window_width=${4:-$(tmux display-message -p '#{window_width}')}

pane_center=$((pane_left + pane_width / 2))
window_center=$((window_width / 2))

if [ "$pane_center" -le "$window_center" ]; then
	popup_x=$((window_width / 2 + 8))
else
	popup_x="8"
fi

tmux display-popup -d "$current_path" -E -w 45% -h 80% -x "$popup_x" -y C \
	"tmux attach-session -t '$POPUP_SESSION'"
