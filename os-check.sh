#!/bin/sh

function mac_requirement() {
    xcode-select --install
    if !(type brew > /dev/null 2>&1); then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        brew bundle
    else
        echo brew already installed
    fi
}

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    # linux
    echo OS: linux
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo OS: macosx
    mac_requirement
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    echo OS: freebsd
else
    echo OS: others
fi

# install oh-my-zsh
if [[ ! -e ~/.oh-my-zsh ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
else
    echo oh-my-zsh already installed
fi

# install vim-runtime
if [[ ! -e ~/.vim_runtime  ]]; then
    git clone --depth=1 https://github.com/lcdsmao/vimrc.git ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh
else
    echo vim_runtime already installed
fi
