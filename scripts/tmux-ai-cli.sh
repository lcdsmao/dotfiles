#!/usr/bin/env bash

# Get the current pane path
CURRENT_PATH="$1"

# Kill all other panes in the current window
tmux kill-pane -a

# Create right pane with 40% width and run the AI CLI selector in it
tmux split-window -h -l 40% -c "$CURRENT_PATH" "bash -c '
# List of all possible AI CLIs
ALL_CLIS=(\"copilot\" \"claude\" \"codex\" \"gemini\")

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

# Remove this when copilot support resume in chat
if [ -n \"\$AI_CLI\" ]; then
    # Ask whether to resume
    RESUME=\$(printf \"No\\nYes\" | fzf --prompt=\"Resume previous session? \" --height=~50% --reverse --border)
    
    if [ \"\$RESUME\" = \"Yes\" ]; then
        # Check if CLI supports --resume parameter or resume command
        case \"\$AI_CLI\" in
            copilot|claude)
                # GitHub Copilot CLI uses --resume parameter
                exec \"\$AI_CLI\" --resume
                ;;
            *)
                # Try resume as a command first, fallback to parameter
                if \"\$AI_CLI\" help 2>&1 | grep -q \"resume\"; then
                    exec \"\$AI_CLI\" resume
                else
                    exec \"\$AI_CLI\" --resume
                fi
                ;;
        esac
    else
        exec \"\$AI_CLI\"
    fi
else
    exec \$SHELL
fi
'"
