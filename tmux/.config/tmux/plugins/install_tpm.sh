#!/bin/bash

# Install TPM without replacing an existing plugin directory.
# Usage: bash install_tpm.sh

set -euo pipefail

TPM_DIR="$HOME/.config/tmux/plugins/tpm"

if [[ -d "$TPM_DIR/.git" ]]; then
  echo "TPM is already installed at $TPM_DIR"
elif [[ -e "$TPM_DIR" || -L "$TPM_DIR" ]]; then
  echo "Error: $TPM_DIR exists but is not a TPM checkout." >&2
  exit 1
else
  mkdir -p -- "$(dirname -- "$TPM_DIR")"
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
