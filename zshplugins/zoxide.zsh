if ! command -v zoxide > /dev/null 2>&1; then
    return
fi

eval "$(zoxide init --cmd ${ZOXIDE_CMD_OVERRIDE:-z} zsh)"

# Jump to the most recently used directory, with tmux integration
# If already in a tmux window with that directory, prompt to switch to it
function j() {
    if [[ $# -ne 0 ]]; then
        z "$@"
        return
    fi

    local current_path
    current_path="$(pwd -P)"
    local target_path
    target_path="$(zoxide query -i 2> /dev/null)" || return
    if [[ -z "$target_path" || "$target_path" == "$current_path" ]]; then
        return
    fi

    target_path="$(cd "$target_path" && pwd -P)" || return

    if [[ -n "$TMUX" ]]; then
        local current_window
        current_window="$(tmux display-message -p '#{window_id}')"
        local target_window=""
        while read -r window_id; do
            local window_path=""
            while read -r pane_path; do
                window_path="$pane_path"
                break
            done < <(tmux list-panes -t "$window_id" -F '#{pane_current_path}')

            if [[ "$window_path" == "$target_path" ]]; then
                target_window="$window_id"
                break
            fi
        done < <(tmux list-windows -F '#{window_id}')

        if [[ -n "$target_window" && "$target_window" != "$current_window" ]]; then
            local reply
            read -r "reply?Jump to window already at $target_path? [y/N] "
            if [[ "$reply" == [yY]* ]]; then
                tmux select-window -t "$target_window"
                return
            fi
        fi
    fi

    cd "$target_path" || return
}
