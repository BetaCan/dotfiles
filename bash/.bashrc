# Omarchy environment (OMARCHY_PATH + PATH), needed even for non-interactive shells
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# If not running interactively, don't do anything else (leave this above the rc source)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source "$OMARCHY_PATH/default/bash/rc"

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# Show the collected Pokemon, or use `pokedex --missing` to see what remains.
pokedex() {
  local dex_file="$HOME/.local/share/pokemon-fastfetch/pokedex"
  local total caught
  total=$(pokemon-colorscripts --list | wc -l)
  caught=$(wc -l < "$dex_file" 2>/dev/null || printf '0')
  printf 'Pokedex: %s/%s caught\n' "$caught" "$total"
  if [[ "$1" == "--missing" ]]; then
    comm -23 <(pokemon-colorscripts --list | sort) <(sort "$dex_file")
  else
    sort -V "$dex_file"
  fi
}

# Refresh the Pokemon logo whenever Fastfetch is run interactively.
fastfetch() {
  if command -v pokemon-colorscripts >/dev/null 2>&1; then
    local dex_dir="$HOME/.local/share/pokemon-fastfetch"
    local dex_file="$dex_dir/pokedex"
    pokemon_logo="$HOME/.cache/pokemon-fastfetch.logo"
    mkdir -p "$dex_dir" "$HOME/.cache"
    pokemon=$(pokemon-colorscripts --list | shuf -n 1)
    if ! grep -Fxq "$pokemon" "$dex_file" 2>/dev/null; then
      printf '%s\n' "$pokemon" >> "$dex_file"
    fi
    if (( RANDOM % 20 == 0 )); then
      pokemon-colorscripts -n "$pokemon" --shiny --no-title > "$pokemon_logo.raw"
    else
      pokemon-colorscripts -n "$pokemon" --no-title > "$pokemon_logo.raw"
    fi
    awk '{
      line = $0
      plain = line
      gsub(/\033\[[0-9;?]*[ -\/]*[@-~]/, "", plain)
      width = length(plain)
      padding = 62 - width
      if (padding > 0) {
        printf "%s\033[8m", line
        for (i = 0; i < padding; i++) printf "x"
        printf "\033[28m\n"
      } else {
        printf "%s\n", line
      }
    }' "$pokemon_logo.raw" > "$pokemon_logo"
    logo_rows=$(wc -l < "$pokemon_logo")
    while (( logo_rows < 20 )); do
      printf '\033[8m%*s\033[28m\n' 62 ''
      logo_rows=$((logo_rows + 1))
    done >> "$pokemon_logo"
    total=$(pokemon-colorscripts --list | wc -l)
    caught=$(wc -l < "$dex_file" 2>/dev/null || printf '0')
    {
      printf '\033[90m┌────────────────────── Pokédex ─────────────────────┐\033[0m\n'
      printf '\033[33m󰍉 Dex:\033[0m %s/%s caught\n' "$caught" "$total"
      printf '\033[90m└────────────────────────────────────────────────────┘\033[0m\n'
    } >> "$pokemon_logo"
  fi
  command fastfetch "$@"
}

# Fast startup greeting with a random Pokemon as the Fastfetch logo.
if command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi
