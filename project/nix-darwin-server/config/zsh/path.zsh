# shellcheck shell=bash
export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"

# home-manager (useUserPackages) per-user profile
export PATH="/etc/profiles/per-user/shunsock/bin:$PATH"

# Homebrew
export PATH="/opt/homebrew/bin:$PATH"

export WEZTERM_CONFIG_FILE=~/.config/wezterm/wezterm.lua
