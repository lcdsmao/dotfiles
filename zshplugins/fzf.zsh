# Setup fzf
# ---------
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
    export PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
fi

# To install useful key bindings and fuzzy completion:
source <(fzf --zsh)

# Setting fd as the default source for fzf
# export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Default Options
export FZF_DEFAULT_OPTS="--history=$HOME/.fzf_history
--bind ctrl-a:select-all,ctrl-d:deselect-all
--bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down"
# Dogrun theme
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:#8085a6,fg+:#d0d0d0,bg:-1,bg+:#262626
  --color=hl:#bdc3e6,hl+:#5fd7ff,info:#929be5,marker:#b871b8
  --color=prompt:#696f9f,spinner:#73c1a9,pointer:#b871b8,header:#32364c
  --color=border:#32364c,label:#aeaeae,query:#d9d9d9
  --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="> "
  --marker=">" --pointer="◆" --separator="─" --scrollbar="│"'

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
# cdf - cd into the directory of the selected file
function cdf() {
    local file
    local dir
    file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir" || return
}

###################################################
# Git
# fco_preview - checkout git branch/tag, with a preview showing the commits between the tag/branch and HEAD
function fco() {
    local tags branches target
    branches=$(
        git --no-pager branch --all \
            --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)" \
            | sed '/^$/d'
    ) || return
    tags=$(
        git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}'
    ) || return
    target=$(
        (
            echo "$branches"
            echo "$tags"
        ) \
            | fzf --no-hscroll --no-multi -n 2 \
                --ansi --preview="git --no-pager log -150 --pretty=format:%s '..{2}'"
    ) || return
    git checkout $(awk '{print $2}' <<< "$target")
}

# fshow - git commit browser
function fshow() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" \
        | fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
            --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# fcs - get git commit sha
# example usage: git rebase -i `fcs`
function fcs() {
    local commits commit
    commits=$(git log --color=always --pretty=oneline --abbrev-commit --reverse "${1:-HEAD}") \
        && commit=$(echo "$commits" | fzf --tac +s +m -e --ansi --reverse) \
        && echo -n "$(echo "$commit" | sed "s/ .*//")"
}
