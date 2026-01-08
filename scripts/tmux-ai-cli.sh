#!/usr/bin/env bash

# Get the current pane path
CURRENT_PATH="$1"

# Kill all other panes in the current window
tmux kill-pane -a

# Create right pane with 40% width and run the AI CLI selector in it
tmux split-window -h -l 40% -c "$CURRENT_PATH" "bash -c '
# List of all possible AI CLIs
ALL_CLIS=(\"copilot\" \"cursor\" \"claude\" \"codex\" \"gemini\")

# Filter to only installed CLIs
INSTALLED_CLIS=()
for cli in \"\${ALL_CLIS[@]}\"; do
    if command -v \"\$cli\" >/dev/null 2>&1; then
        INSTALLED_CLIS+=(\"\$cli\")
    fi
done

if [ \${#INSTALLED_CLIS[@]} -eq 0 ]; then
    echo \"No AI CLI tools found. Please install one of: \${ALL_CLIS[*]}\"
    echo \"\"
    exec \$SHELL
fi

# Show only installed CLIs in fzf
AI_CLI=\$(printf \"%s\\n\" \"\${INSTALLED_CLIS[@]}\" | fzf --prompt=\"Select AI CLI: \" --height=~50% --reverse --border)

if [ -n \"\$AI_CLI\" ]; then
    exec \"\$AI_CLI\"
else
    exec \$SHELL
fi
'"
