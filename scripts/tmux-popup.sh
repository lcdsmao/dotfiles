#!/usr/bin/env bash
set -e

POPUP_SESSION="popup"

configure_popup_session() {
	tmux set-option -t "$POPUP_SESSION" status-right '' >/dev/null
	tmux set-hook -t "$POPUP_SESSION" after-new-window "run-shell '~/.config/scripts/tmux-popup.sh --configure-window #{window_id}'" >/dev/null
}

configure_popup_window() {
	local window_id="$1"

	tmux set-window-option -t "$window_id" pane-border-lines single >/dev/null
	tmux set-window-option -t "$window_id" pane-border-indicators colour >/dev/null
	tmux set-window-option -t "$window_id" pane-border-status off >/dev/null
	tmux set-window-option -t "$window_id" pane-border-format "" >/dev/null
	tmux set-option -t "$window_id" @sidebar_auto_create off >/dev/null
}

session_pane_records() {
	local session_name="$1"
	local window_id

	tmux list-windows -t "$session_name" -F '#{window_id}' 2>/dev/null | while read -r window_id; do
		tmux list-panes -t "$window_id" -F '#{pane_id}	#{pane_current_path}' 2>/dev/null || true
	done
}

session_unique_paths() {
	local session_name="$1"

	session_pane_records "$session_name" | awk -F'	' '{ print $2 }' | sort -u
}

purge_stale_popup_panes() {
	local invoke_session="$1"
	local invoke_paths
	local popup_panes
	local stale_paths
	local pane_id
	local pane_path
	local stale_path

	invoke_paths=$(session_unique_paths "$invoke_session")
	popup_panes=$(session_pane_records "$POPUP_SESSION")
	stale_paths=$(comm -23 \
		<(printf '%s\n' "$popup_panes" | awk -F'	' '{ print $2 }' | sort -u) \
		<(printf '%s\n' "$invoke_paths" | sort -u))

	while IFS= read -r stale_path; do
		[ -n "$stale_path" ] || continue

		while IFS=$'\t' read -r pane_id pane_path; do
			[ -n "$pane_id" ] || continue
			[ "$pane_path" = "$stale_path" ] || continue
			tmux kill-pane -t "$pane_id"
		done <<EOF
$popup_panes
EOF
	done <<EOF
$stale_paths
EOF
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
invoke_session=$(tmux display-message -p '#{session_name}')

if [ "${1:-}" = "--configure-window" ]; then
	configure_popup_window "$2"
	exit 0
fi

if tmux has-session -t "$POPUP_SESSION" 2>/dev/null; then
	purge_stale_popup_panes "$invoke_session"
fi

if ! tmux has-session -t "$POPUP_SESSION" 2>/dev/null; then
	window_id=$(tmux new-session -d -P -F '#{window_id}' -s "$POPUP_SESSION" -c "$current_path" "exec \"${SHELL:-/bin/sh}\"")
	tmux set-window-option -t "$window_id" @popup_path "$current_path" >/dev/null
	configure_popup_session
	configure_popup_window "$window_id"
else
	configure_popup_session
	if ! window_id=$(find_window_for_path "$current_path"); then
		window_id=$(tmux new-window -d -P -F '#{window_id}' -t "$POPUP_SESSION:" -c "$current_path" "exec \"${SHELL:-/bin/sh}\"")
		tmux set-window-option -t "$window_id" @popup_path "$current_path" >/dev/null
	fi
	configure_popup_window "$window_id"
fi

tmux select-window -t "$window_id"

pane_left=${2:-$(tmux display-message -p '#{pane_left}')}
pane_width=${3:-$(tmux display-message -p '#{pane_width}')}
window_width=${4:-$(tmux display-message -p '#{window_width}')}

pane_center=$((pane_left + pane_width / 2))
# Position popup to the right-half unless the pane center is in the
# rightmost quarter of the window. Use strict less-than against
# three-quarters of the window width.
threshold=$((window_width * 3 / 4))

if [ "$pane_center" -lt "$threshold" ]; then
    popup_x=$((window_width / 2 + 8))
else
    popup_x="8"
fi

tmux display-popup -d "$current_path" -E -w 45% -h 80% -x "$popup_x" -y C \
	"tmux attach-session -t '$POPUP_SESSION'"
