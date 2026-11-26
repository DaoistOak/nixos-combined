{ pkgs, inputs, ... }:

with pkgs;
[
  atuin
  avizo
  awww
  chafa
  cliphist
  copilot-language-server
  flameshot
  gpu-screen-recorder
  # Temporarily disabled: hermes-agent's nix package applies a patchelf patch
  # that no longer applies to patchelf 0.15.2, breaking all home builds.
  # Re-enable once upstream fixes the packaging.
  # inputs.hermes-agent.packages."x86_64-linux".default
  hypridle
  # hyprlandGuiutils  # disabled: hyprtoolkit build fails (needs hyprutils >=0.14.2, pinned is 0.14.0)
  # hyprlandGuiutils
  hyprlock
  hyprnome

  hyprpicker
  hyprpolkitagent
  hyprprop
  hyprshot
  hyprsunset
  hyprwhspr-rs
  jrnl
  jujutsu
  kdePackages.qqc2-desktop-style
  kdePackages.qtstyleplugin-kvantum
  klassy
  mew
  neovide
  pay-respects
  quickshell
  socat
  (pkgs.writeShellApplication {
    name = "phone-idle-inhibitor";
    text = builtins.readFile ../scripts/phone-idle-inhibitor;
  })
  hyprland-guiutils
]
