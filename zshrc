# Profile for zsh shell
# $ time zsh -i -c exit
# zmodload zsh/zprof

# Keep PATH variable clean
if [ -f /etc/profile ]; then
    PATH=""
    source /etc/profile
fi

# Disable oh-my-zsh auto-update checks
zstyle ':omz:update' mode disabled

# Source antidote
source "${HOME}/.antidote/antidote.zsh"
antidote load

export TERM="xterm-256color"

# Due to the following issue:
# https://github.com/zsh-users/zsh-syntax-highlighting/issues/295
# Syntax highlighting is really slow when pasting long text. This speeds it
# up to just a slight delay
zstyle ':bracketed-paste-magic' active-widgets '.self-*'

# Set language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Path
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.docker/bin:$PATH"
export PATH="$PATH:$HOME/.zshconfig/plugins/bin"

# ignore ctrl + d
setopt ignoreeof

# Enable command line editor
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-x' edit-command-line

# Alias
alias vi=nvim
alias o='open .'
alias c='tput clear'

# Profile end
# zprof
