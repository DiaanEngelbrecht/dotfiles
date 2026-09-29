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

  for tool in sesh zoxide wt cargo-sweep; do
    command -v "$tool" >/dev/null || echo "note: $tool not installed (package: ${tool/wt/worktrunk})"
  done
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
link .config/sesh/sesh.toml
link .config/worktrunk/config.toml
link .cargo/config.toml
link .local/bin/cargo-sweep-weekly

# ──────────────────────────────────────────────────────────────────────────────
# Weekly cargo sweep of ~/repos: launchd on macOS, systemd user timer on Linux.
# ──────────────────────────────────────────────────────────────────────────────

schedule_cargo_sweep() {
  local sweep="$HOME/.local/bin/cargo-sweep-weekly"

  case "$(uname)" in
    Darwin)
      local label=local.cargo-sweep
      local plist="$HOME/Library/LaunchAgents/$label.plist"
      mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
      sed "s|__HOME__|$HOME|g" "$DOTFILES/Library/LaunchAgents/$label.plist" > "$plist"
      launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
      launchctl bootstrap "gui/$(id -u)" "$plist"
      echo "scheduled: weekly cargo sweep (launchd $label, log ~/Library/Logs/cargo-sweep.log)"
      ;;
    Linux)
      if command -v systemctl >/dev/null && systemctl --user show-environment >/dev/null 2>&1; then
        link .config/systemd/user/cargo-sweep.service
        link .config/systemd/user/cargo-sweep.timer
        systemctl --user daemon-reload
        systemctl --user enable --now cargo-sweep.timer
        echo "scheduled: weekly cargo sweep (systemd user timer, log: journalctl --user -u cargo-sweep)"
        echo "note: user timers only run while logged in; to run always: sudo loginctl enable-linger $USER"
      else
        echo "note: no systemd user session; schedule the sweep with crontab -e:"
        echo "  30 9 * * 1 $sweep >> $HOME/.cargo-sweep.log 2>&1"
      fi
      ;;
  esac
}

schedule_cargo_sweep

echo
echo "Done. Remember:"
echo "  - Create ~/.zshrc.local for machine-specific exports and secrets"
echo "  - Install tmux plugins: prefix + I (after starting tmux with TPM)"
echo "  - Install nvim plugins: open nvim and let lazy.nvim sync"
