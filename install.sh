#!/usr/bin/env bash
# Symlink tracked dotfiles into $HOME. Idempotent: re-running is safe.
# Existing non-symlink files at target paths are backed up to <path>.bak.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ──────────────────────────────────────────────────────────────────────────────
# Prerequisites — required by .zshrc / .tmux.conf. Idempotent.
# ──────────────────────────────────────────────────────────────────────────────

install_prereqs() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
  fi

  local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [ ! -d "$p10k_dir" ]; then
    echo "installing powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
  fi

  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "installing tmux plugin manager (TPM)..."
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi

  if [ ! -f "$HOME/.asdf/asdf.sh" ]; then
    echo "note: asdf not installed (optional). To install: brew install asdf"
  fi
}

install_prereqs

# ──────────────────────────────────────────────────────────────────────────────
# Symlink tracked dotfiles into $HOME.
# ──────────────────────────────────────────────────────────────────────────────

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
