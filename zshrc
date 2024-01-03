# Unalias ls in case if we already alias ls to exa
unalias ls > /dev/null 2>&1

#  Brew auto completion.
#  Need to call before oh-my-zsh.
if type brew &> /dev/null; then
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

    autoload -Uz compinit
    compinit
fi

source "$HOME/.zshconfig/antigen/antigen.zsh"

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle autojump
antigen bundle adb
antigen bundle ripgrep
antigen bundle gitignore
antigen bundle pip
antigen bundle command-not-found
antigen bundle asdf

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions

# Local plugins.
antigen bundle "$HOME/.zshconfig/plugins"

# Load the theme.
# antigen theme robbyrussell

# Antigen check files
export ANTIGEN_AUTO_CONFIG=false
export ANTIGEN_CHECK_FILES=("$HOME"/.zshrc "$HOME"/.zshconfig/plugins/*)

# Tell Antigen that you're done.
antigen apply

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
export PATH="$PATH:$HOME/.rvm/bin"
export PATH="$PATH:$HOME/.maestro/bin"
export PATH="$PATH:$HOME/.flashlight/bin"
export PATH="/usr/local/sbin:$PATH"
export PATH="$PATH:$HOME/.zshconfig/plugins/bin"
export PATH="$HOME/.rbenv/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PYENV_ROOT="$HOME/.pyenv"

# startship
eval "$(starship init zsh)"

# fuck
eval "$(thefuck --alias)"

# pyenv
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# ignore ctrl + d
setopt ignoreeof

# start tmux automatically
# if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
#     exec tmux new-session -A -s main
# fi

# Alias
alias vi=nvim
alias copypath='pwd | pbcopy' # copy current path to clipboard
alias o='open .'
alias c='clear'
alias ls='exa'
