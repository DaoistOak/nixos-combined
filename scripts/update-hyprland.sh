#!/usr/bin/env bash
# Weekly Hyprland update script
# Run this weekly to update Hyprland to the latest git version

set -e

echo "Updating Hyprland to latest git version..."

# Update the flake lock for hyprland input only
nix flake lock --update-input hyprland

# Get the new commit hash
NEW_REV=$(nix eval --json --file flake.lock '.nodes.hyprland.locked.rev' | sed 's/"//g')
NEW_DATE=$(date +%Y-%m-%d)

echo "Updated to commit: $NEW_REV on $NEW_DATE"

# Update the URL in flake.nix to pin to the new commit
sed -i "s|url = \"github:hyprwm/Hyprland/[^\"]*\";|url = \"github:hyprwm/Hyprland/$NEW_REV\";|g" flake.nix

# Update the comment in flake.nix with new date
sed -i "s/# Last updated: .*/# Last updated: $NEW_DATE/" flake.nix

echo "Updated flake.nix with new commit info"
echo "Run 'sudo nixos-rebuild switch --flake .#Overlord' to apply the update"