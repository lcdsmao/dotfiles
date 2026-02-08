#!/usr/bin/env bash
# Launch applications in smart popup windows
# Usage: wezterm-popup-launcher.sh [command] [path]
#   command: Application to launch (default: zsh)
#   path: Working directory (default: current directory)
#
# Behavior:
# - If in tmux inside wezterm: open in new positioned wezterm window
# - If in tmux only: open in tmux popup
# - Otherwise: run command directly

set -e

COMMAND="${1:-zsh}"
CURRENT_PATH="${2:-.}"

# Helper function to set OSC 1337 user var with tmux DCS passthrough
# This wraps the OSC sequence so it passes through tmux to wezterm
set_user_var() {
  local name="$1"
  local value="$2"
  local b64
  local esc
  b64=$(printf '%s' "$value" | base64 | tr -d '\n')
  # Use actual ESC character (octal 033)
  esc=$(printf '\033')
  # DCS passthrough: ESC P tmux ; ESC ESC ] 1337 ; SetUserVar=name=value ESC ESC \ ESC \
  printf "%sPtmux;%s%s]1337;SetUserVar=%s=%s%s%s\\%s\\\\" "$esc" "$esc" "$esc" "$name" "$b64" "$esc" "$esc" "$esc"
}

if [ -n "$TMUX" ] && [ -n "$WEZTERM_UNIX_SOCKET" ]; then
  # Scenario A: In tmux inside wezterm - use wezterm window

  # Resolve command to absolute path to avoid "command not found" errors
  COMMAND_PATH=$(command -v "$COMMAND" 2> /dev/null || printf '%s' "$COMMAND")

  # Get the pane's TTY to write the escape sequence directly to it
  pane_tty=$(tmux display-message -p '#{pane_tty}')

  # Send command and path to wezterm popup launcher
  # Format: "command,path"
  if [ -w "$pane_tty" ]; then
    set_user_var popup_launch "$COMMAND_PATH,$CURRENT_PATH" > "$pane_tty"
  else
    # Fallback: print to stdout (when called directly)
    set_user_var popup_launch "$COMMAND_PATH,$CURRENT_PATH"
  fi

elif [ -n "$TMUX" ]; then
  # Scenario B: In tmux only - use tmux popup

  # Create popup with new session
  tmux display-popup -d "$CURRENT_PATH" -E -w 60% -h 80% -x C -y C \
    "tmux new-session 'tmux set status off; $COMMAND'"

else
  # Scenario C: Not in tmux - run command directly
  cd "$CURRENT_PATH"
  exec "$COMMAND"
fi
