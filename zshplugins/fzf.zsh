# Setup fzf
# ---------
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
fi

# To install useful key bindings and fuzzy completion:
# $(brew --prefix)/opt/fzf/install
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Setting fd as the default source for fzf
# export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Dogrun Color
export FZF_DEFAULT_OPTS="--history=$HOME/.fzf_history
--color=fg:#9ea3c0,bg:#222433,hl:#545c8c
--color=fg+:#535f98,bg+:#2a2c3f,hl+:#929be5
--color=info:#545c8c,prompt:#929be5,pointer:#73c1a9
--color=marker:#73c1a9,spinner:#b5ae7d,header:#87afaf
--bind ctrl-a:select-all,ctrl-d:deselect-all"

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# ------------
# Begin custom functions

###################################################
# Preview
function fp() {
  fzf --preview '[[ $(file --mime {}) =~ binary ]] \
    && echo {} is a binary file \
    || (bat --style=numbers --color=always {} \
    || highlight -O ansi -l {} \
    || coderay {} \
    || rougify {} \
    || cat {}) 2> /dev/null | head -500'
}

###################################################
# Change directory
# fdr - cd to selected parent directory
function fdr() {
  local dirs=()
  get_parent_dirs() {
    if [[ -d "${1}" ]]; then dirs+=("$1"); else return; fi
    if [[ "${1}" == '/' ]]; then
      for _dir in "${dirs[@]}"; do echo "$_dir"; done
    else
      get_parent_dirs "$(dirname "$1")"
    fi
  }
  local DIR
  DIR=$(get_parent_dirs "$(realpath "${1:-$PWD}")" | fzf-tmux --tac)
  cd "$DIR" || return
}

###################################################
# fd - cd to selected directory
# function fd() {
#     local dir
#     dir=$(find ${1:-.} -path '*/\.*' -prune \
#         -o -type d -print 2> /dev/null | fzf +m) &&
#         cd "$dir"
#     }

# cdf - cd into the directory of the selected file
function cdf() {
  local file
  local dir
  file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir" || return
}

###################################################
# Git
# fbr - checkout git branch (including remote branches)
function fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) \
    && branch=$(echo "$branches" | fzf-tmux -d $((2 + $(wc -l <<< "$branches"))) +m) \
    && git checkout "$(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")"
}

# fga - view status
function fga() {
  modified_files=$(git status --short | awk '{print $2}') \
    && selected_files=$(echo "$modified_files" \
      | fzf -m --preview 'git diff head {} | (bat --style=numbers --color=always || cat {}) 2> /dev/null') \
    && git add "$selected_files"
}

# fga - view status
function fgd() {
  modified_files=$(git diff "$1" --name-only) \
    && echo "$modified_files" \
    | fzf -m --preview "git diff $1 {} \
    | (bat --style=numbers --color=always || cat {}) 2> /dev/null"
}

###################################################
# Homebrew
# Install (one or multiple) selected application(s)
# using "brew search" as source input
# mnemonic [B]rew [I]nstall [P]lugin
function bip() {
  local inst
  inst=$(brew search | fzf -m)

  if [[ $inst ]]; then
    for prog in $(echo $inst); do
      brew install "$prog"
    done
  fi
}

# Update (one or multiple) selected application(s)
# mnemonic [B]rew [U]pdate [P]lugin
function bup() {
  local upd
  upd=$(brew leaves | fzf -m)

  if [[ $upd ]]; then
    for prog in $(echo $upd); do
      brew upgrade $prog
    done
  fi
}

# Delete (one or multiple) selected application(s)
# mnemonic [B]rew [C]lean [P]lugin (e.g. uninstall)
function bcp() {
  local uninst
  uninst=$(brew leaves | fzf -m)

  if [[ $uninst ]]; then
    for prog in $(echo $uninst); do
      brew uninstall "$prog"
    done
  fi
}

###################################################
# Interactive cd
# Suggested by @mgild Like normal cd but opens an interactive navigation window when called with no arguments. For ls, use -FG instead of --color=always on osx.
function cd() {
  if [[ "$#" != 0 ]]; then
    builtin cd "$@"
    return
  fi
  while true; do
    local lsd=$(echo ".." && /bin/ls -p | grep '/$' | sed 's;/$;;')
    local dir="$(printf '%s\n' "${lsd[@]}" \
      | fzf --reverse --preview ' \
        __cd_nxt="$(echo {})"; \
        __cd_path="$(echo $(pwd)/${__cd_nxt} | sed "s;//;/;")"; \
        echo $__cd_path; \
        echo; \
        /bin/ls -pG "${__cd_path}"; \
        ')"
    [[ ${#dir} != 0 ]] || return 0
    builtin cd "$dir" &> /dev/null
  done
}

###################################################
# Autojump
function j() {
  if [[ "$#" -ne 0 ]]; then
    cd "$(autojump $@)"
    return
  fi
  cd "$(autojump -s | sed -e :a -e '$d;N;2,7ba' -e 'P;D' | awk '{print $2}' | fzf --height 40% --reverse --inline-info)"
}

###################################################
# Android emulator
function avdr() {
  selected_avd="$(emulator -list-avds | fzf)" \
    && (emulator @"$selected_avd" "$@" > /dev/null 2>&1 &)
}

function adb_select_device() {
  local devs
  local selected_dev
  local dev_cnt
  devs="$(command adb devices -l | awk 'NR > 1 { print }')"
  dev_cnt="$(echo "$devs" | wc -l)"
  if [[ $dev_cnt -le 1 ]]; then
    selected_dev="$devs"
  else
    selected_dev="$(echo "$devs" | fzf)"
  fi
  echo "$selected_dev" | awk '{ print $1 }'
}

# adb
function adb_fzf() {
  command adb -s "$(adb_select_device)" "$@"
}
