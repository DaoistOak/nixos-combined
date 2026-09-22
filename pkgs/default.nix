# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs, inputs, ... }:

let
  # Patch nix-search-tv to always exec zsh instead of its own bash.
  ns = pkgs.writeShellApplication {
    name = "ns";
    runtimeInputs = with pkgs; [
      fzf
      nix-search-tv
    ];
    text =
      builtins.replaceStrings
        [
          "NIX_SHELL_CMD='nix-shell --run $SHELL -p $(echo \"{}\" | sed \"s:nixpkgs/::g\"\""
        ]
        [
          "NIX_SHELL_CMD='nix-shell --run zsh -p zsh $(echo \"{}\" | sed \"s:nixpkgs/::g\"\""
        ]
        (builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh");
  };
  user-packages = with pkgs; [
    ns
    atuin
    avizo
    awww
    chafa
    cliphist
    flameshot
    gpu-screen-recorder
    inputs.hermes-agent.packages."x86_64-linux".default
    hypridle
    hyprlock
    hyprnome
    inputs.hyprpanel.packages."x86_64-linux".default
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
      text = (builtins.readFile ../scripts/phone-idle-inhibitor);
    })
  ];

  system-packages = with pkgs; [
    # --- Desktop Environment & Wayland Compositor ---
    ags
    swayidle

    # --- Web Browsers & Communication ---
    brave
    ferdium
    firefox
    inputs.zen-browser.packages."x86_64-linux".default
    kdePackages.kdeconnect-kde
    qutebrowser
    thunderbird
    ungoogled-chromium
    vesktop

    # --- Development Tools & Compilers ---
    automake
    binutils
    bintools
    cargo
    cmake
    devenv
    direnv
    gcc
    gdb
    git
    gnumake
    jq
    lazygit
    luarocks
    nil
    ninja
    nodejs
    nixfmt
    nixfmt-tree
    opencode
    patchelf
    pkg-config
    python3
    vscode-fhs

    # --- Text Editors & Terminal Utilities ---
    bat
    copyq
    eza
    fish
    neovim
    pcmanfm
    superfile
    vim
    yazi
    zellij
    zoxide
    zsh
    kdePackages.kate
    kdePackages.yakuake

    # --- System Administration, Monitoring & Power ---
    amdgpu_top
    auto-cpufreq
    brightnessctl
    btop
    cpufrequtils
    kdePackages.kpmcore
    lact
    lm_sensors
    networkmanager_dmenu
    networkmanagerapplet
    nh
    nix-ld
    nix-output-monitor
    nix-search-tv
    nvd
    pciutils
    powertop
    radeontop
    ryzenadj
    appimage-run

    # --- Virtualization & Containers ---
    distrobox
    lazydocker
    spice
    spice-gtk
    virt-manager

    # --- Gaming & Compatibility ---
    gamescope
    goverlay
    hydralauncher
    heroic
    lutris
    mangohud
    scrcpy
    vkd3d
    vkd3d-proton
    winboat
    wineWow64Packages.stable

    # --- Media, Graphics & CAD ---
    blender
    cava
    drawy
    ffmpeg-full
    grim
    grimblast
    # Screenshot/color helpers: slurp (region select for grim), swappy and
    # satty (annotate/editor backends). hyprpicker lives in user-packages.
    slurp
    swappy
    satty
    # Wayland screen recording + ImageMagick (`magick`) for conversions
    wl-screenrec
    imagemagick
    kdePackages.dragon
    kicad-small
    mpv
    # Keypress visualization (from NUR, not in nixpkgs)
    nur.repos.milahu.keyviz
    playerctl
    spotube

    # --- Network & Connectivity ---
    bluez-tools
    curl
    dnsmasq
    freerdp
    gnirehtet
    picocom
    proton-vpn
    qbittorrent
    screen
    wget

    # --- Security, Storage & Document Viewers ---
    busybox
    fuse3
    keepassxc
    kdePackages.okular
    ntfs3g
    p7zip
    rpi-imager
    # OCR
    tesseract
    unzip
    wpsoffice
    zathura

    # --- AI, CLI Toys & Novelty ---
    hollywood
    ollama
    tgpt

    # --- Graphics Drivers, Codecs & Display Libraries ---
    dxvk
    mesa-demos
    vulkan-hdr-layer-kwin6
    vulkan-tools
    vulkan-validation-layers

    # --- System Libraries, Themes & Fonts ---
    adi1090x-plymouth-themes
    adwaita-icon-theme
    alsa-utils
    bleachbit
    catppuccin-cursors.macchiatoLight
    catppuccin-kvantum
    catppuccin-papirus-folders
    code-cursor-fhs
    dart-sass
    # Provides the gio command (used by syncthing for mime/open handling); the
    # gvfs daemons themselves come via services.gvfs.enable.
    glib
    jre
    killall
    libnotify
    lohit-fonts.devanagari
    openjfx
    # Open Sound Control command-line client
    osc
    papirus-folders
    qalculate-qt
    terminus_font
    times-newer-roman
    wl-clipboard
    xclip
  ];
in
{
  user-packages = user-packages;
  system-packages = system-packages;
}
