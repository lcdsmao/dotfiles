function ktd() { 
    git diff $1 --name-only --relative | grep '\.kt[s"]\?$' | xargs ktlint $2 --relative . 
}
