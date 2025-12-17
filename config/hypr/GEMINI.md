# Gemini Context: Hyprland Configuration

This directory contains the configuration for the Hyprland Wayland compositor, managed using Nix.

## Directory Overview

This is a non-code project. The directory contains a set of `.nix` files that configure various aspects of the Hyprland environment. The configuration is modular, with different settings separated into individual files.

-   `hyprland.nix`: The main entry point, which imports all other configuration files.
-   `hypridle.nix`: Configures the idle daemon for Hyprland, including timeouts for screen locking and sleeping.
-   `hyprlock.nix`: Configures the lock screen appearance and behavior.
-   `settings/`: This directory contains more specific configuration files for different aspects of Hyprland:
    -   `animations.nix`: Configures animations and effects.
    -   `colors.nix`: Defines the color scheme.
    -   `decorations.nix`: Configures window decorations.
    -   `displays.nix`: Configures display settings.
    -   `input.nix`: Configures input devices like keyboards and mice.
    -   `keybinds.nix`: Defines custom keybindings for various actions.
    -   `misc.nix`: Contains miscellaneous settings.
    -   `plugins.nix`: Configures Hyprland plugins.
    -   `startup.nix`: Defines startup applications and environment variables.
    -   `windowrules.nix`: Sets rules for how different application windows should be handled.
-   `scripts/`: This directory contains shell scripts used by the configuration.

## Usage

The contents of this directory are used to configure the Hyprland desktop environment. The configuration is likely applied by a Nix-based system configuration tool like `home-manager` or `NixOS`.

To apply changes to the Hyprland configuration, you would typically edit the relevant `.nix` file and then run the appropriate command to rebuild the system configuration, such as `home-manager switch`.
