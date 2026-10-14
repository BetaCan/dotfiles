#!/usr/bin/env bash
#
# Install these dotfiles into $HOME.
#
# Existing target files are backed up as <file>.bak.<timestamp> before being
# replaced, so nothing is lost. Re-run any time; each run re-backs up.
#
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ts="$(date +%s)"

install_file() {
  local src="$1" dest="$2"

  if [[ ! -f "$src" ]]; then
    echo "skip (missing in repo): $src" >&2
    return 0
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ -e "$dest" ]]; then
    cp "$dest" "$dest.bak.$ts"
    echo "backed up  $dest -> $dest.bak.$ts"
  fi

  cp "$src" "$dest"
  echo "installed  $dest"
}

install_file "$repo/ghostty/.config/config"          "$HOME/.config/ghostty/config"
install_file "$repo/alacritty/.config/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
install_file "$repo/kitty/.config/kitty.conf"         "$HOME/.config/kitty/kitty.conf"
install_file "$repo/foot/.config/foot.ini"            "$HOME/.config/foot/foot.ini"
install_file "$repo/fastfetch/.config/config.jsonc"   "$HOME/.config/fastfetch/config.jsonc"
install_file "$repo/bash/.bashrc"                     "$HOME/.bashrc"
install_file "$repo/bash/.bash_profile"               "$HOME/.bash_profile"

cat <<'EOF'

Configs installed. Remaining manual steps:

  1. Packages
       omarchy pkg add ghostty alacritty kitty foot fastfetch
       omarchy pkg aur add pokemon-colorscripts-git
     (or, on plain Arch:)
       sudo pacman -S --needed ghostty alacritty kitty foot fastfetch
       yay -S pokemon-colorscripts-git

  2. Font
       Install "JetBrainsMono Nerd Font" (e.g. ttf-jetbrains-mono-nerd).

  3. Reload
       Open a new terminal. Fastfetch will show a random Pokemon on startup.

Backups from this run use the suffix .bak.<timestamp> next to each file.
EOF
