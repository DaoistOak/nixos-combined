{ pkgs, inputs, ... }:

  with pkgs; [
    atuin
    avizo
    awww
    chafa
    cliphist
    copilot-language-server
    flameshot
    gpu-screen-recorder
    inputs.hermes-agent.packages."x86_64-linux".default
    hypridle
    hyprlandGuiutils
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
  ]