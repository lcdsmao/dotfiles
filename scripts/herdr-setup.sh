#!/usr/bin/env bash

set -e

if ! command -v herdr >/dev/null 2>&1; then
  exit 0
fi

herdr plugin install paulbkim-dev/vim-herdr-navigation --ref 53e318c772c4d3b7fbd904ac43bcf3e5b5d8b244 --yes >/dev/null
