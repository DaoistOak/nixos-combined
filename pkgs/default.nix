# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs, inputs, ... }:

let
  ns = pkgs.writeShellApplication {
    name = "ns";
    runtimeInputs = with pkgs; [
      fzf
      nix-search-tv
    ];
    text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
  };
  user-packages = with pkgs; [
    ns
    # Kvantum widget style engine; required so QT_STYLE_OVERRIDE=kvantum renders
    # for regular Qt widget apps.
    kdePackages.qtstyleplugin-kvantum
    # KDE's QtQuick Controls style ("org.kde.desktop"). It reads the KDE color
    # scheme (e.g. CatppuccinMacchiatoMauve), so the KDE polkit agent's
    # QtQuick dialog matches the catppuccin theme instead of the unstyled
    # default.
    kdePackages.qqc2-desktop-style
    # Flake-specific packages
    hyprnome
    hyprprop
    hyprsunset
    hyprshot
    flameshot
    cliphist
    gpu-screen-recorder
    jrnl
    jujutsu
    chafa
    # nur.repos.mikilio.ttf-ms-fonts
    klassy
    pay-respects
  ];

  system-packages = with pkgs; [
    # GUI Applications
    ags
    arduino-ide
    avizo
    blender
    brave
    inputs.zen-browser.packages."x86_64-linux".default
    copyq
    drawy
    ferdium
    firefox
    heroic
    goverlay
    hyprlock
    inputs.hyprpanel.packages."x86_64-linux".default
    hyprpolkitagent
    hydralauncher
    kdePackages.bluedevil
    kdePackages.bluez-qt
    kdePackages.dragon
    kdePackages.flatpak-kcm
    kdePackages.kate
    kdePackages.kpmcore
    kdePackages.okular
    kdePackages.plasma-nm
    kdePackages.plasma-pa
    kdePackages.plymouth-kcm
    kdePackages.sddm-kcm
    kdePackages.yakuake
    kdePackages.kde-cli-tools
    kdePackages.plasma-desktop
    kdePackages.plasma-workspace
    kdePackages.plasma5support
    kdePackages.kwin
    kdePackages.kglobalaccel
    kdePackages.libplasma
    kdePackages.kdeconnect-kde
    keepassxc
    kicad-small
    lact
    qalculate-qt
    networkmanagerapplet
    pcmanfm
    (popcorntime.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        substituteInPlace $out/opt/popcorntime/node_modules/butter-settings-popcorntime.app/index.js \
          --replace-quiet "'https://yts.mx/'" "'https://yts.gg/'"
        substituteInPlace $out/opt/popcorntime/src/app/lib/views/movie_detail.js \
          --replace-quiet 'https://yts.mx/' 'https://yts.gg/'
      '';
    }))
    proton-vpn
    qbittorrent
    qutebrowser
    rofi
    rpi-imager
    thunderbird
    ungoogled-chromium
    vesktop
    virt-manager
    vscode-fhs
    waybar
    waypaper
    # webcord-vencord
    winboat
    wpsoffice
    zathura

    # TUI Applications
    alsa-utils
    amdgpu_top
    auto-cpufreq
    bat
    brightnessctl
    busybox
    btop
    cargo
    cpufrequtils
    curl
    jq
    direnv
    devenv
    distrobox
    docker-compose
    podman
    eza
    ffmpeg
    fish
    freerdp
    gemini-cli
    git
    gnirehtet
    gnumake
    grim
    grimblast
    hollywood
    jre
    openjfx
    kbd
    killall
    lazydocker
    lazygit
    lm_sensors
    lutris
    mesa-demos
    mpv
    neovim
    networkmanager
    networkmanager_dmenu
    ninja
    nodejs
    ntfs3g
    oh-my-zsh
    ollama
    opencode
    p7zip
    pciutils
    picocom
    playerctl
    quickshell
    powertop
    ryzenadj
    screen
    spotube
    awww
    swayidle
    syncthing
    tgpt
    thermald
    tlp
    unzip
    upower
    util-linux
    vim
    wget
    wl-clipboard
    xclip
    superfile
    yazi
    zellij
    zoxide
    zsh

    # Dependencies
    bluez
    bluez-tools
    cairo
    dart-sass
    gvfs
    libgtop
    mangohud
    python3
    # python3Packages.pip
    # python311Packages.opencv4
    # (pkgs.python311.withPackages (
    # ps: with ps; [
    # opencv4
    # pyserial
    # ]
    # ))
    qt5.qtbase
    qt6.qtwayland
    libxcb
    libx11
    libxext
    libxau
    libxdmcp
    libxcursor
    libxrandr
    libxinerama
    libxi
    gtk3
    gdk-pixbuf
    libjpeg
    libpng
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    wineWow64Packages.stable

    # Utilities
    adwaita-icon-theme
    adi1090x-plymouth-themes
    appimage-run
    catppuccin-cursors.macchiatoLight
    catppuccin-kvantum
    catppuccin-papirus-folders
    code-cursor-fhs
    gamescope
    hypridle
    papirus-folders
    terminus_font
    times-newer-roman

    # Libraries & System Dependencies
    (catppuccin-sddm.override {
      flavor = "macchiato";
      accent = "mauve";
      font = "JetBrains Mono";
      fontSize = "9";
      background = "${./../nixos/sddm/wallpaper}";
      loginBackground = true;
    })
    fuse3
    automake
    cmake
    gcc
    gdb
    binutils
    bintools
    patchelf
    coreutils-full
    dxvk
    glibc
    glibc.dev
    icu
    libgcc
    libgccjit
    libvirt
    libxkbcommon
    luarocks
    eglexternalplatform
    egl-wayland
    libGL
    libGLU
    libva
    libvdpau
    libvdpau-va-gl
    libtheora
    speex
    libgudev
    nil
    pkg-config
    radeontop
    virglrenderer
    virtiofsd
    vkd3d
    vkd3d-proton
    vulkan-loader
    vulkan-tools
    vulkan-validation-layers
    vulkan-hdr-layer-kwin6
    zlib
    arduino-cli
    dbus
    dnsmasq
    flatpak
    fprintd
    libnotify
    pulseaudio
    spice
    spice-gtk
    spice-vdagent
    speechd
    nh
    nix-output-monitor
    nix-search-tv
    nixfmt
    nixfmt-tree
    lohit-fonts.devanagari
    nix-ld
    stdenv.cc.cc.lib
    libglvnd
    nvd
  ];
in
{
  user-packages = user-packages;
  system-packages = system-packages;
}
