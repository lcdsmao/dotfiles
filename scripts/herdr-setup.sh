#!/usr/bin/env bash

set -e

if ! command -v herdr >/dev/null 2>&1; then
  exit 0
fi

herdr plugin install paulbkim-dev/vim-herdr-navigation --ref 79679dacc791f70fc34de8b29a3cf9706c0f5b2f --yes >/dev/null
