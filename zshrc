# Keep PATH variable clean
if [ -f /etc/profile ]; then
    PATH=""
    source /etc/profile
fi

# Configure plugin settings BEFORE loading antidote
export NVM_LAZY_LOAD=true  # Lazy-load nvm (biggest perf win)
export NVM_COMPLETION=true # Enable nvm completion
export NVM_AUTO_USE=true   # Auto-switch Node version based on .nvmrc

# Disable oh-my-zsh auto-update checks
zstyle ':omz:update' mode disabled

# Source antidote
source "${HOME}/.antidote/antidote.zsh"

# Set the root name of the plugins files (.txt and .zsh) antidote will use
zsh_plugins="${ZDOTDIR:-$HOME}/.zsh_plugins"

#Ensure the .zsh_plugins.txt file exists so you can add plugins
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

# Generate a new static file whenever .zsh_plugins.txt is updated
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
    antidote bundle < ${zsh_plugins}.txt >| ${zsh_plugins}.zsh
fi

# Source your static plugins file
source ${zsh_plugins}.zsh

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
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$PATH:$HOME/flutter/bin"
export PATH="$PATH:$HOME/.pub-cache/bin"
export PATH="$PATH:$HOME/.maestro/bin"
export PATH="$PATH:$HOME/.flashlight/bin"
export PATH="/usr/local/sbin:$PATH"
export PATH="$PATH:$HOME/.zshconfig/plugins/bin"

# ignore ctrl + d
setopt ignoreeof

# Enable command line editor
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-x' edit-command-line

# start tmux automatically
# if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
#     exec tmux new-session -A -s main
# fi

# Alias
alias vi=nvim
alias o='open .'
alias c='clear'
