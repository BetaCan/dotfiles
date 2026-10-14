# Terminal dotfiles

My shell and terminal emulator configuration, captured so a fresh machine can
be brought back to the same feel with a quick copy.

Everything here is built for **[Omarchy](https://omarchy.org/)** (Arch Linux +
Hyprland). The terminal configs pull their colors from Omarchy's active theme
via `include`/`import` lines, and the bash files source Omarchy's shell
bootstrap. If you are not on Omarchy, see [Adapting to a non-Omarchy
system](#adapting-to-a-non-omarchy-system).

## What's inside

| Repo path | Installs to | What it is |
|-----------|-------------|------------|
| `ghostty/.config/config` | `~/.config/ghostty/config` | Ghostty config (default terminal) |
| `alacritty/.config/alacritty.toml` | `~/.config/alacritty/alacritty.toml` | Alacritty config |
| `kitty/.config/kitty.conf` | `~/.config/kitty/kitty.conf` | Kitty config |
| `foot/.config/foot.ini` | `~/.config/foot/foot.ini` | Foot config |
| `fastfetch/.config/config.jsonc` | `~/.config/fastfetch/config.jsonc` | Fastfetch layout (with the Pokémon logo hook) |
| `bash/.bashrc` | `~/.bashrc` | Shell rc: Omarchy defaults + Pokémon fastfetch + `pokedex` |
| `bash/.bash_profile` | `~/.bash_profile` | Sources `~/.bashrc` |

Shared terminal settings across all four emulators: **JetBrainsMono Nerd Font**
at **size 9**, 14px padding, block cursor with no blink, `Shift+Insert` paste /
`Ctrl+Insert` copy, and `Shift+Enter` / `Alt+Shift+Enter` sent as CSI-u so
TUIs (tmux, editors, agents) can tell them apart from plain Enter.

## Requirements

**Packages**

| Package | Source | Why |
|---------|--------|-----|
| `ghostty` `alacritty` `kitty` `foot` | official repos | The four terminal emulators (install only the ones you use) |
| `fastfetch` | official repos | System info shown on shell startup |
| `pokemon-colorscripts-git` | AUR | Prints the random Pokémon used as the fastfetch logo |

Install them on Arch/Omarchy:

```bash
# Official packages
omarchy pkg add ghostty alacritty kitty foot fastfetch
#   or: sudo pacman -S --needed ghostty alacritty kitty foot fastfetch

# AUR package (Pokémon sprites)
omarchy pkg aur add pokemon-colorscripts-git
#   or: yay -S pokemon-colorscripts-git
```

**Fonts**

The `JetBrainsMono Nerd Font` is used by every terminal. On Omarchy it is
already present; otherwise install a Nerd Font build (e.g. `ttf-jetbrains-mono-nerd`).

## Install

Copy the files into `$HOME`, backing up anything already there:

```bash
git clone git@github.com:BetaCan/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` mirrors the table above, moving any existing target aside as
`<file>.bak.<timestamp>` before writing. Nothing is deleted, so you can always
roll back by copying a `.bak` file over the new one.

Prefer to do it by hand? The mapping is just:

```bash
cp ghostty/.config/config             ~/.config/ghostty/config
cp alacritty/.config/alacritty.toml   ~/.config/alacritty/alacritty.toml
cp kitty/.config/kitty.conf           ~/.config/kitty/kitty.conf
cp foot/.config/foot.ini              ~/.config/foot/foot.ini
cp fastfetch/.config/config.jsonc     ~/.config/fastfetch/config.jsonc
cp bash/.bashrc                       ~/.bashrc
cp bash/.bash_profile                 ~/.bash_profile
```

## The Pokémon fastfetch logo

By default Omarchy's fastfetch shows the Omarchy logo
(`~/.config/omarchy/branding/about.txt`). This setup replaces it with a random
Pokémon sprite plus a "Pokédex" counter that tracks how many distinct Pokémon
you have been shown.

It works in two parts:

1. **`bash/.bashrc`** defines a `fastfetch` wrapper. On each interactive shell
   it picks a random Pokémon with `pokemon-colorscripts`, renders it, pads it to
   a fixed width, appends a Pokédex box, and writes the result to
   `~/.cache/pokemon-fastfetch.logo`. It also records the Pokémon in
   `~/.local/share/pokemon-fastfetch/pokedex`.
2. **`fastfetch/.config/config.jsonc`** is a copy of Omarchy's fastfetch layout
   whose `logo.source` points at that cached file.

Because the fastfetch config lives in `~/.config/` (not `/etc/`), it is
user-owned and survives `omarchy-settings` updates.

**Useful commands** (defined in `.bashrc`):

```bash
pokedex            # show how many Pokémon you've caught and list them
pokedex --missing  # list the ones you haven't seen yet
```

**Turn the Pokémon off:** delete `~/.config/fastfetch/config.jsonc` (fastfetch
falls back to the Omarchy logo) or remove the `fastfetch` function and startup
call from `~/.bashrc`.

## Adapting to a non-Omarchy system

The configs assume Omarchy in two ways:

- **Theme colors.** Each terminal `include`s / `import`s a file under
  `~/.local/state/omarchy/current/theme/`. On a non-Omarchy machine, remove
  those lines (Ghostty's uses a `?` prefix and is already treated as optional)
  and set colors directly.
- **Shell bootstrap.** `bash/.bashrc` starts by sourcing
  `/usr/share/omarchy/default/bash/env-bootstrap` and `$OMARCHY_PATH/default/bash/rc`.
  On a non-Omarchy machine, drop those two lines and keep the rest (the
  Pokémon fastfetch and `pokedex` helpers are self-contained).

## Notes

- Fastfetch runs on every interactive shell by design. If shell startup feels
  slow, comment out the final `fastfetch` call in `~/.bashrc`.
- `alacritty` and `kitty` are configured even if you only use Ghostty; their
  configs are harmless when the emulator isn't installed.
- No secrets, keys, or tokens belong in this repository.
