#!/usr/bin/env bash
# Symlink tracked dotfiles into $HOME. Idempotent: re-running is safe.
# Existing non-symlink files at target paths are backed up to <path>.bak.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local rel="$1"
  local src="$DOTFILES/$rel"
  local dst="$HOME/$rel"

  if [ ! -e "$src" ]; then
    echo "skip (missing in repo): $rel"
    return
  fi

  mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    echo "backup: $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi

  ln -s "$src" "$dst"
  echo "linked: ~/$rel"
}

link .zshrc
link .zshenv
link .zprofile
link .p10k.zsh
link .tmux.conf
link .config/ghostty/config
link .config/nvim

echo
echo "Done. Remember:"
echo "  - Create ~/.zshrc.local for machine-specific exports and secrets"
echo "  - Install tmux plugins: prefix + I (after starting tmux with TPM)"
echo "  - Install nvim plugins: open nvim and let lazy.nvim sync"
