if (( $+commands[zoxide] )); then
    eval "$(zoxide init --cmd ${ZOXIDE_CMD_OVERRIDE:-z} zsh)"

    function j() {
        if [[ $# -eq 0 ]]; then
            zi
        else
            z "$@"
        fi
    }
fi
