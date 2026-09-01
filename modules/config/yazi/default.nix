{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Active theme roles (modules/config/colors resolves the persisted selection).
  a = config.colors.active;
  h = v: "#${v}";
  # Named accent hue with a role/ANSI fallback so every theme stays decent.
  acc = name: fallback: a.accents.${name} or fallback;
  accent = h a.accent;
  fg = h a.text;
  sub0 = h a.subtext0;
  sub1 = h a.subtext1;
  base = h a.base;
  surface0 = h a.surface0;
  surface1 = h a.surface1;
  surface2 = h a.surface2;
  overlay0 = h a.overlay0;
  overlay1 = h a.overlay1;
  overlay2 = h a.overlay2;
  green = h (acc "green" (builtins.elemAt a.ansi 2));
  red = h (acc "red" (builtins.elemAt a.ansi 1));
  yellow = h (acc "yellow" (builtins.elemAt a.ansi 3));
  pink = h (acc "pink" (builtins.elemAt a.ansi 5));
  teal = h (acc "teal" (acc "cyan" (builtins.elemAt a.ansi 6)));
  blue = h (acc "blue" (builtins.elemAt a.ansi 4));
  sapphire = h (acc "sapphire" teal);
  flamingo = h (acc "flamingo" (acc "maroon" (builtins.elemAt a.ansi 9)));
in
{
  programs.yazi = {
    enable = true;
    # yazi is already a system package (pkgs/default.nix); keep it out of the
    # home profile so it is not installed twice.
    package = null;

    settings = {
      # [mgr] manager options (show_hidden etc. live under this section, not at
      # the top level — yazi rejects unknown root keys as "must be 1-20
      # characters in kebab-case").
      mgr = {
        show_hidden = true;
      };
      # Text files open in nvim by default via the `edit` opener.
      opener = {
        edit = [
          {
            run = "nvim %s";
            block = true;
            desc = "Edit with nvim";
          }
        ];
        image = [
          {
            run = "gwenview %s";
            desc = "Open with Gwenview";
          }
        ];
        pdf = [
          {
            run = "okular %s";
            desc = "Open with Okular";
          }
        ];
        word = [
          {
            run = "wps %s";
            desc = "Open with WPS Office";
          }
        ];
      };
      open = {
        # Prepend: takes precedence over yazi's defaults (which route text/*
        # to $EDITOR anyway, but this pins it to nvim via the opener above).
        prepend_rules = [
          {
            mime = "text/*";
            use = "edit";
          }
          {
            mime = "image/*";
            use = "image";
          }
          {
            mime = "application/pdf";
            use = "pdf";
          }
          # Word docs (.doc / .docx)
          {
            mime = "application/msword";
            use = "word";
          }
          {
            mime = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            use = "word";
          }
        ];
      };
    };

    # Theme driven by the active selection, with a transparent background
    # (`reset`) so the terminal's background shows through. catppuccin.yazi is
    # disabled below so we can control the background ourselves.
    theme = {
      app.overall = {
        bg = "reset";
      };

      mgr = {
        cwd = {
          fg = accent;
        };

        find_keyword = {
          fg = yellow;
          italic = true;
        };
        find_position = {
          fg = pink;
          bg = "reset";
          italic = true;
        };

        marker_copied = {
          fg = green;
          bg = green;
        };
        marker_cut = {
          fg = red;
          bg = red;
        };
        marker_marked = {
          fg = teal;
          bg = teal;
        };
        marker_selected = {
          fg = accent;
          bg = accent;
        };

        count_copied = {
          fg = base;
          bg = green;
        };
        count_cut = {
          fg = base;
          bg = red;
        };
        count_selected = {
          fg = base;
          bg = accent;
        };

        border_symbol = "│";
        border_style = {
          fg = overlay1;
        };

        syntect_theme = "~/.config/yazi/Catppuccin-macchiato.tmTheme";
      };

      tabs = {
        active = {
          fg = base;
          bg = fg;
          bold = true;
        };
        inactive = {
          fg = fg;
          bg = surface1;
        };
      };

      mode = {
        normal_main = {
          fg = base;
          bg = accent;
          bold = true;
        };
        normal_alt = {
          fg = accent;
          bg = surface0;
        };

        select_main = {
          fg = base;
          bg = green;
          bold = true;
        };
        select_alt = {
          fg = green;
          bg = surface0;
        };

        unset_main = {
          fg = base;
          bg = flamingo;
          bold = true;
        };
        unset_alt = {
          fg = flamingo;
          bg = surface0;
        };
      };

      indicator = {
        parent = {
          fg = base;
          bg = fg;
        };
        current = {
          fg = base;
          bg = accent;
        };
        preview = {
          fg = base;
          bg = fg;
        };
      };

      status = {
        sep_left = {
          open = "";
          close = "";
        };
        sep_right = {
          open = "";
          close = "";
        };

        progress_label = {
          fg = "#ffffff";
          bold = true;
        };
        progress_normal = {
          fg = green;
          bg = surface1;
        };
        progress_error = {
          fg = yellow;
          bg = red;
        };

        perm_type = {
          fg = blue;
        };
        perm_read = {
          fg = yellow;
        };
        perm_write = {
          fg = red;
        };
        perm_exec = {
          fg = green;
        };
        perm_sep = {
          fg = overlay1;
        };
      };

      input = {
        border = {
          fg = accent;
        };
        title = { };
        value = { };
        selected = {
          reversed = true;
        };
      };

      pick = {
        border = {
          fg = accent;
        };
        active = {
          fg = pink;
        };
        inactive = { };
      };

      confirm = {
        border = {
          fg = accent;
        };
        title = {
          fg = accent;
        };
        body = { };
        list = { };
        btn_yes = {
          reversed = true;
        };
        btn_no = { };
      };

      cmp = {
        border = {
          fg = accent;
        };
      };

      tasks = {
        border = {
          fg = accent;
        };
        title = { };
        hovered = {
          fg = pink;
          bold = true;
        };
      };

      which = {
        mask = {
          bg = surface0;
        };
        cand = {
          fg = teal;
        };
        rest = {
          fg = overlay2;
        };
        desc = {
          fg = pink;
        };
        separator = "  ";
        separator_style = {
          fg = surface2;
        };
      };

      help = {
        on = {
          fg = teal;
        };
        run = {
          fg = pink;
        };
        desc = {
          fg = overlay2;
        };
        hovered = {
          bg = surface2;
          bold = true;
        };
        footer = {
          fg = fg;
          bg = surface1;
        };
      };

      notify = {
        title_info = {
          fg = teal;
        };
        title_warn = {
          fg = yellow;
        };
        title_error = {
          fg = red;
        };
      };

      filetype.rules = [
        # Media
        {
          mime = "image/*";
          fg = yellow;
        }
        {
          mime = "{audio,video}/*";
          fg = pink;
        }

        # Archives
        {
          mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
          fg = red;
        }

        # Documents
        {
          mime = "application/{pdf,doc,rtf}";
          fg = sapphire;
        }

        # Virtual file system
        {
          mime = "vfs/{absent,stale}";
          fg = surface1;
        }

        # Special file
        {
          url = "*";
          is = "orphan";
          bg = red;
        }
        {
          url = "*";
          is = "exec";
          fg = green;
        }

        # Dummy file
        {
          url = "*";
          is = "dummy";
          bg = red;
        }
        {
          url = "*/";
          is = "dummy";
          bg = red;
        }

        # Fallback (directories use the accent)
        {
          url = "*/";
          fg = accent;
        }
      ];

      spot = {
        border = {
          fg = accent;
        };
        title = {
          fg = accent;
        };
        tbl_cell = {
          fg = accent;
          reversed = true;
        };
        tbl_col = {
          bold = true;
        };
      };

      icon = {
        dirs = [
          {
            name = ".config";
            text = "";
            fg = accent;
          }
          {
            name = ".git";
            text = "";
            fg = accent;
          }
          {
            name = ".github";
            text = "";
            fg = accent;
          }
          {
            name = ".npm";
            text = "";
            fg = accent;
          }
          {
            name = "Desktop";
            text = "";
            fg = accent;
          }
          {
            name = "Development";
            text = "";
            fg = accent;
          }
          {
            name = "Documents";
            text = "";
            fg = accent;
          }
          {
            name = "Downloads";
            text = "";
            fg = accent;
          }
          {
            name = "Library";
            text = "";
            fg = accent;
          }
          {
            name = "Movies";
            text = "";
            fg = accent;
          }
          {
            name = "Music";
            text = "";
            fg = accent;
          }
          {
            name = "Pictures";
            text = "";
            fg = accent;
          }
          {
            name = "Public";
            text = "";
            fg = accent;
          }
          {
            name = "Videos";
            text = "";
            fg = accent;
          }
        ];
        conds = [
          # Special files
          {
            "if" = "orphan";
            text = "";
            fg = fg;
          }
          {
            "if" = "link";
            text = "";
            fg = sub0;
          }
          {
            "if" = "block";
            text = "";
            fg = yellow;
          }
          {
            "if" = "char";
            text = "";
            fg = yellow;
          }
          {
            "if" = "fifo";
            text = "";
            fg = yellow;
          }
          {
            "if" = "sock";
            text = "";
            fg = yellow;
          }
          {
            "if" = "sticky";
            text = "";
            fg = yellow;
          }
          {
            "if" = "dummy";
            text = "";
            fg = red;
          }

          # Fallback
          {
            "if" = "dir";
            text = "";
            fg = accent;
          }
          {
            "if" = "exec";
            text = "";
            fg = green;
          }
          {
            "if" = "!dir";
            text = "";
            fg = fg;
          }
        ];
      };
    };
  };

  # Disable the catppuccin-generated theme (opaque background) and write our own
  # transparent variant above. Keep catppuccin's syntax-highlight .tmTheme file.
  catppuccin.yazi.enable = false;

  home.file."yazi/Catppuccin-macchiato.tmTheme".source =
    "${config.catppuccin.sources.bat}/Catppuccin Macchiato.tmTheme";
}
