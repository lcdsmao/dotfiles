#!/usr/bin/env bash

set -e

if ! command -v herdr >/dev/null 2>&1; then
  exit 0
fi

herdr plugin install paulbkim-dev/vim-herdr-navigation --ref 79679dacc791f70fc34de8b29a3cf9706c0f5b2f --yes >/dev/null
herdr plugin install meerzulee/herdr-float --yes >/dev/null
HERDR_FLOAT_ROOT="$(herdr plugin list --plugin herdr-float --json | jq -r '.result.plugins[0].plugin_root // empty')"
HERDR_FLOAT_TMUX_CONFIG="$HERDR_FLOAT_ROOT/tmux.conf"
sed -i.bak 's/^set-option -g prefix None$/set-option -g prefix C-s/' "$HERDR_FLOAT_TMUX_CONFIG"
if ! grep -q '^bind-key Space detach-client$' "$HERDR_FLOAT_TMUX_CONFIG"; then
  cat >>"$HERDR_FLOAT_TMUX_CONFIG" <<'EOF'
# Match Herdr's prefix+space binding while the popup owns input.
bind-key Space detach-client
EOF
fi
rm -f "$HERDR_FLOAT_TMUX_CONFIG.bak"

herdr integration install opencode >/dev/null
