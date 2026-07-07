#!/usr/bin/env bash

set -euo pipefail

HERDR_BIN="${HERDR_BIN_PATH:-herdr}"

if ! command -v "$HERDR_BIN" >/dev/null 2>&1; then
	exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
	exit 1
fi

CURRENT_PANE_JSON=""
WORKSPACE_ID="${HERDR_ACTIVE_WORKSPACE_ID:-}"
CURRENT_CWD="${HERDR_ACTIVE_PANE_CWD:-}"

if [ -z "$WORKSPACE_ID" ] || [ -z "$CURRENT_CWD" ]; then
	CURRENT_PANE_JSON="$($HERDR_BIN pane current)"
fi

if [ -z "$WORKSPACE_ID" ]; then
	WORKSPACE_ID="$(printf '%s\n' "$CURRENT_PANE_JSON" | jq -r '.result.pane.workspace_id')"
fi

if [ -z "$CURRENT_CWD" ]; then
	CURRENT_CWD="$(printf '%s\n' "$CURRENT_PANE_JSON" | jq -r '.result.pane.foreground_cwd // .result.pane.cwd // env.HOME')"
fi

TABS_JSON="$($HERDR_BIN tab list --workspace "$WORKSPACE_ID")"
MAIN_TAB_ID="$(printf '%s\n' "$TABS_JSON" | jq -r '.result.tabs[] | select(.number == 1) | .tab_id' | head -n 1)"

if [ -z "$MAIN_TAB_ID" ]; then
	exit 1
fi

$HERDR_BIN tab rename "$MAIN_TAB_ID" main >/dev/null

TERMINAL_TAB_ID="$(printf '%s\n' "$TABS_JSON" | jq -r '.result.tabs[] | select(.label == "terminal") | .tab_id' | head -n 1)"
if [ -z "$TERMINAL_TAB_ID" ]; then
	$HERDR_BIN tab create --workspace "$WORKSPACE_ID" --cwd "$CURRENT_CWD" --label terminal --no-focus >/dev/null
fi

PANES_JSON="$($HERDR_BIN pane list --workspace "$WORKSPACE_ID")"
MAIN_TAB_PANES="$(printf '%s\n' "$PANES_JSON" | jq --arg tab_id "$MAIN_TAB_ID" '[.result.panes[] | select(.tab_id == $tab_id)]')"
AI_PANE_ID="$(printf '%s\n' "$MAIN_TAB_PANES" | jq -r '.[] | select(.label == "ai") | .pane_id' | head -n 1)"

if [ -z "$AI_PANE_ID" ]; then
	MAIN_PANE_ID="$(printf '%s\n' "$MAIN_TAB_PANES" | jq -r '.[0].pane_id')"
	LAYOUT_JSON="$($HERDR_BIN pane layout --pane "$MAIN_PANE_ID")"
	SPLIT_SOURCE_PANE_ID="$(printf '%s\n' "$LAYOUT_JSON" | jq -r '.result.layout.panes | sort_by(.rect.x, .rect.y) | .[0].pane_id')"

	AI_PANE_ID="$($HERDR_BIN pane split "$SPLIT_SOURCE_PANE_ID" --direction right --focus | jq -r '.result.pane.pane_id')"
	$HERDR_BIN pane rename "$AI_PANE_ID" ai >/dev/null
	$HERDR_BIN pane run "$AI_PANE_ID" "bash ~/.config/scripts/tmux-ai-cli-selector.sh" >/dev/null
else
	$HERDR_BIN tab focus "$MAIN_TAB_ID" >/dev/null
	LEFT_NEIGHBOR_ID="$($HERDR_BIN pane neighbor --direction left --pane "$AI_PANE_ID" | jq -r '.result.neighbor.neighbor_pane_id // empty')"
	if [ -n "$LEFT_NEIGHBOR_ID" ]; then
		$HERDR_BIN pane focus --direction right --pane "$LEFT_NEIGHBOR_ID" >/dev/null
	fi
fi
