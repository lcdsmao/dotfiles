#!/bin/bash
mac_requirement() {
  xcode-select --install
  if ! (type brew > /dev/null 2>&1); then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew bundle
  else
    echo brew already installed
  fi
}

linux_requirement() {
  if ! (type brew > /dev/null 2>&1); then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew bundle
  else
    echo brew already installed
  fi
}

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  # linux
  echo OS: linux
  linux_requirement
elif [[ "$OSTYPE" == "darwin"* ]]; then
  echo OS: macosx
  mac_requirement
elif [[ "$OSTYPE" == "freebsd"* ]]; then
  echo OS: freebsd
else
  echo OS: others
fi
