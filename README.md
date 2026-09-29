# dotfiles

zsh (oh-my-zsh + powerlevel10k), tmux, Neovim, Ghostty, sesh and worktrunk,
plus a weekly `cargo sweep` of `~/repos`.

`install.sh` symlinks everything into `$HOME` (existing files are backed up to
`<path>.bak`), installs oh-my-zsh, powerlevel10k and TPM if missing, and
schedules the cargo sweep (launchd on macOS, a systemd user timer on Linux).
It is safe to re-run.

## Prerequisites

### Arch Linux

```sh
sudo pacman -S --needed base-devel git curl zsh tmux neovim ghostty zoxide \
  rustup go nodejs npm lua-language-server aws-cli ripgrep fd ttf-firacode-nerd
chsh -s /usr/bin/zsh

rustup default stable
rustup component add rust-analyzer clippy rustfmt
cargo install cargo-sweep worktrunk

# sesh, from the AUR (or: go install github.com/joshmedeski/sesh/v2@latest)
yay -S sesh-bin

# Claude Code (sesh opens a `claude` window in each work session)
curl -fsSL https://claude.ai/install.sh | bash
```

Optional: `yay -S asdf-vm`.

The cargo sweep runs as a systemd user timer, which only fires while you are
logged in. To have it run regardless:

```sh
sudo loginctl enable-linger "$USER"
```

### macOS

Install [Homebrew](https://brew.sh), then:

```sh
brew install git tmux neovim zoxide sesh go node lua-language-server awscli ripgrep fd
brew install --cask ghostty font-fira-code-nerd-font

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup component add rust-analyzer clippy rustfmt
cargo install cargo-sweep worktrunk

curl -fsSL https://claude.ai/install.sh | bash
```

Optional: `brew install asdf`.

## Install

```sh
git clone git@github.com:DiaanEngelbrecht/dotfiles.git ~/repos/dotfiles
~/repos/dotfiles/install.sh
```

Then:

- Start tmux and press `prefix + I` to install tmux plugins.
- Open nvim and let lazy.nvim sync; Mason installs the remaining language
  servers (`:Mason`, or `<leader>ls`).
- Put machine-specific exports and secrets in `~/.zshrc.local` (gitignored).

## Cargo sweep

`~/.local/bin/cargo-sweep-weekly [days]` deletes build artifacts under
`~/repos` unused for `days` (default 7) and artifacts from uninstalled
toolchains. It runs Mondays at 09:30.

- macOS log: `~/Library/Logs/cargo-sweep.log`
- Linux log: `journalctl --user -u cargo-sweep`
