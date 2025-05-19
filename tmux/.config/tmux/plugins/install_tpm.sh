#!/bin/bash

TPM_DIR="$HOME/.config/tmux/plugins/tpm"

if [ -d "$TPM_DIR" ]; then
  echo "TPM is already installed at $TPM_DIR"
else
  mkdir -p $(basedir $TPM_DIR)
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
