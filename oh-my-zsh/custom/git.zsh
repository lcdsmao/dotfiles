function gitD2w() {
    for k in $(git branch --format="%(refname:short)"); do
        if (($(git log -1 --since='2 week ago' -s $k|wc -l)==0)); then
            echo git branch -D $k
        fi
    done
}
