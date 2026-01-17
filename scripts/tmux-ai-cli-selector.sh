#!/usr/bin/env bash

# List of all possible AI CLIs
ALL_CLIS=("opencode" "copilot" "claude" "codex" "gemini")

# File to store the last selected CLI in system cache
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
LAST_CLI_FILE="$CACHE_DIR/tmux-ai-cli-last"

# Filter to only installed CLIs
INSTALLED_CLIS=()
for cli in "${ALL_CLIS[@]}"; do
	if command -v "$cli" >/dev/null 2>&1; then
		INSTALLED_CLIS+=("$cli")
	fi
done

if [ ${#INSTALLED_CLIS[@]} -eq 0 ]; then
	echo "No AI CLI tools found. Please install one of: ${ALL_CLIS[*]}"
	echo ""
	exec "$SHELL"
fi

# Sort installed CLIs with the last used one first
SORTED_CLIS=()
if [ -f "$LAST_CLI_FILE" ]; then
	LAST_CLI=$(cat "$LAST_CLI_FILE")
	# Add last used CLI first if it's still installed
	for cli in "${INSTALLED_CLIS[@]}"; do
		if [ "$cli" = "$LAST_CLI" ]; then
			SORTED_CLIS+=("$cli")
			break
		fi
	done
	# Add remaining CLIs
	for cli in "${INSTALLED_CLIS[@]}"; do
		if [ "$cli" != "$LAST_CLI" ]; then
			SORTED_CLIS+=("$cli")
		fi
	done
else
	SORTED_CLIS=("${INSTALLED_CLIS[@]}")
fi

# Show only installed CLIs in fzf (sorted with last used first)
AI_CLI=$(printf "%s\n" "${SORTED_CLIS[@]}" | fzf --prompt="Select AI CLI: " --height=~50% --reverse --border)

if [ -n "$AI_CLI" ]; then
	# Save the selected CLI for next time (ensure cache directory exists)
	mkdir -p "$CACHE_DIR"
	echo "$AI_CLI" >"$LAST_CLI_FILE"

	# Only show resume option for copilot (others can resume inside chat session)
	if [ "$AI_CLI" = "copilot" ]; then
		RESUME=$(printf "No\nYes" | fzf --prompt="Resume previous session? " --height=~50% --reverse --border)

		if [ "$RESUME" = "Yes" ]; then
			exec "$AI_CLI" --resume
		else
			exec "$AI_CLI"
		fi
	else
		exec "$AI_CLI"
	fi
else
	exec "$SHELL"
fi
