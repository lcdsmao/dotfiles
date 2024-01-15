export PYENV_ROOT="$HOME/.pyenv"
if type pyenv &> /dev/null; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi
