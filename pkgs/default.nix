# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs, inputs, ... }:
{
  # example = pkgs.callPackage ./example { };
  user-packages = with pkgs; [
    # Flake-specific packages
    inputs.caelestia-shell.packages.${pkgs.system}.with-cli
    hyprnome
    hyprprop
    hyprsunset
    # nur.repos.mikilio.ttf-ms-fonts
    klassy
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
    firefox
    genymotion
    heroic
    hyprlock
    hyprpanel
    hyprpolkitagent
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
    keepassxc
    kicad-small
    kitty
    # lact
    lutris
    networkmanagerapplet
    pcmanfm
    popcorntime
    protonvpn-gui
    qbittorrent
    qutebrowser
    rofi
    (pkgs.rpi-imager.overrideAttrs (oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++ [ pkgs.qt6.qt5compat ];
    }))
    thunderbird
    ungoogled-chromium
    vesktop
    viber
    virt-manager
    vscode-fhs
    waybar
    waypaper
    # webcord-vencord
    winboat
    wpsoffice

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
    distrobox
    docker-compose
    podman
    eza
    ffmpeg
    fish
    freerdp
    fzf
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
    mesa-demos
    mpv
    neovim
    networkmanager
    networkmanager_dmenu
    ninja
    nodejs
    ntfs3g
    (octaveFull.withPackages (
      ps: with ps; [
        signal # Signal processing (sawtooth, filter, etc.)
        control # Control systems
        image # Image processing
        statistics # Statistical functions
        io # File I/O operations
        linear-algebra # Advanced linear algebra
        struct # Structured data
        geometry # Geometry functions
      ]
    ))
    oh-my-zsh
    ollama
    opencode
    p7zip
    pciutils
    picocom
    powertop
    screen
    speechd
    steam-run
    swww
    swayidle
    syncthing
    scilab-bin
    tgpt
    thermald
    tlp
    tmux
    unzip
    upower
    util-linux
    vim
    vimPlugins.nvchad
    wget
    wl-clipboard
    xclip
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
    python3Full
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
    xorg.libX11
    xorg.libXext
    xorg.libXau
    xorg.libXdmcp
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXi
    gtk3
    gdk-pixbuf
    libjpeg
    libpng
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    wineWowPackages.full

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
    coreutils-full
    dxvk
    glibc
    glibc.dev
    icu77
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
    nixfmt
    nixfmt-tree
    lohit-fonts.devanagari
    nix-ld
    stdenv.cc.cc.lib
    libglvnd
    nvd
  ];
}
