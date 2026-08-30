{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.yazi = {
    enable = true;
    # yazi is already a system package (pkgs/default.nix); keep it out of the
    # home profile so it is not installed twice.
    package = null;

    settings = {
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

    # Catppuccin macchiato theme, but with a transparent background (`reset`)
    # so the terminal's background shows through. catppuccin.yazi is disabled
    # below so we can control the background ourselves.
    theme = {
      app.overall = {
        bg = "reset";
      };

      mgr = {
        cwd = {
          fg = "#8bd5ca";
        };

        find_keyword = {
          fg = "#eed49f";
          italic = true;
        };
        find_position = {
          fg = "#f5bde6";
          bg = "reset";
          italic = true;
        };

        marker_copied = {
          fg = "#a6da95";
          bg = "#a6da95";
        };
        marker_cut = {
          fg = "#ed8796";
          bg = "#ed8796";
        };
        marker_marked = {
          fg = "#8bd5ca";
          bg = "#8bd5ca";
        };
        marker_selected = {
          fg = "#c6a0f6";
          bg = "#c6a0f6";
        };

        count_copied = {
          fg = "#24273a";
          bg = "#a6da95";
        };
        count_cut = {
          fg = "#24273a";
          bg = "#ed8796";
        };
        count_selected = {
          fg = "#24273a";
          bg = "#c6a0f6";
        };

        border_symbol = "│";
        border_style = {
          fg = "#8087a2";
        };

        syntect_theme = "~/.config/yazi/Catppuccin-macchiato.tmTheme";
      };

      tabs = {
        active = {
          fg = "#24273a";
          bg = "#cad3f5";
          bold = true;
        };
        inactive = {
          fg = "#cad3f5";
          bg = "#494d64";
        };
      };

      mode = {
        normal_main = {
          fg = "#24273a";
          bg = "#c6a0f6";
          bold = true;
        };
        normal_alt = {
          fg = "#c6a0f6";
          bg = "#363a4f";
        };

        select_main = {
          fg = "#24273a";
          bg = "#a6da95";
          bold = true;
        };
        select_alt = {
          fg = "#a6da95";
          bg = "#363a4f";
        };

        unset_main = {
          fg = "#24273a";
          bg = "#f0c6c6";
          bold = true;
        };
        unset_alt = {
          fg = "#f0c6c6";
          bg = "#363a4f";
        };
      };

      indicator = {
        parent = {
          fg = "#24273a";
          bg = "#cad3f5";
        };
        current = {
          fg = "#24273a";
          bg = "#c6a0f6";
        };
        preview = {
          fg = "#24273a";
          bg = "#cad3f5";
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
          fg = "#a6da95";
          bg = "#494d64";
        };
        progress_error = {
          fg = "#eed49f";
          bg = "#ed8796";
        };

        perm_type = {
          fg = "#8aadf4";
        };
        perm_read = {
          fg = "#eed49f";
        };
        perm_write = {
          fg = "#ed8796";
        };
        perm_exec = {
          fg = "#a6da95";
        };
        perm_sep = {
          fg = "#8087a2";
        };
      };

      input = {
        border = {
          fg = "#c6a0f6";
        };
        title = { };
        value = { };
        selected = {
          reversed = true;
        };
      };

      pick = {
        border = {
          fg = "#c6a0f6";
        };
        active = {
          fg = "#f5bde6";
        };
        inactive = { };
      };

      confirm = {
        border = {
          fg = "#c6a0f6";
        };
        title = {
          fg = "#c6a0f6";
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
          fg = "#c6a0f6";
        };
      };

      tasks = {
        border = {
          fg = "#c6a0f6";
        };
        title = { };
        hovered = {
          fg = "#f5bde6";
          bold = true;
        };
      };

      which = {
        mask = {
          bg = "#363a4f";
        };
        cand = {
          fg = "#8bd5ca";
        };
        rest = {
          fg = "#939ab7";
        };
        desc = {
          fg = "#f5bde6";
        };
        separator = "  ";
        separator_style = {
          fg = "#5b6078";
        };
      };

      help = {
        on = {
          fg = "#8bd5ca";
        };
        run = {
          fg = "#f5bde6";
        };
        desc = {
          fg = "#939ab7";
        };
        hovered = {
          bg = "#5b6078";
          bold = true;
        };
        footer = {
          fg = "#cad3f5";
          bg = "#494d64";
        };
      };

      notify = {
        title_info = {
          fg = "#8bd5ca";
        };
        title_warn = {
          fg = "#eed49f";
        };
        title_error = {
          fg = "#ed8796";
        };
      };

      filetype.rules = [
        # Media
        {
          mime = "image/*";
          fg = "#eed49f";
        }
        {
          mime = "{audio,video}/*";
          fg = "#f5bde6";
        }

        # Archives
        {
          mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
          fg = "#ed8796";
        }

        # Documents
        {
          mime = "application/{pdf,doc,rtf}";
          fg = "#91d7e3";
        }

        # Virtual file system
        {
          mime = "vfs/{absent,stale}";
          fg = "#494d64";
        }

        # Special file
        {
          url = "*";
          is = "orphan";
          bg = "#ed8796";
        }
        {
          url = "*";
          is = "exec";
          fg = "#a6da95";
        }

        # Dummy file
        {
          url = "*";
          is = "dummy";
          bg = "#ed8796";
        }
        {
          url = "*/";
          is = "dummy";
          bg = "#ed8796";
        }

        # Fallback
        {
          url = "*/";
          fg = "#c6a0f6";
        }
      ];

      spot = {
        border = {
          fg = "#c6a0f6";
        };
        title = {
          fg = "#c6a0f6";
        };
        tbl_cell = {
          fg = "#c6a0f6";
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
            fg = "#c6a0f6";
          }
          {
            name = ".git";
            text = "";
            fg = "#c6a0f6";
          }
          {
            name = ".github";
            text = "";
            fg = "#c6a0f6";
          }
          {
            name = ".npm";
            text = "";
            fg = "#c6a0f6";
          }
          {
            name = "Desktop";
            text = "";
            fg = "#c6a0f6";
          }
          {
            name = "Development";
            text = "";
            fg = "#c6a0f6";
          }
          {
            name = "Documents";
            text = "";
            fg = "#c6a0f6";
          }
          {
            name = "Downloads";
            text = "";
            fg = "#c6a0f6";
          }
          {
            name = "Library";
            text = "";
            fg = "#c6a0f6";
          }
          {
            name = "Movies";
            text = "";
            fg = "#c6a0f6";
          }
          {
            name = "Music";
            text = "";
            fg = "#c6a0f6";
          }
          {
            name = "Pictures";
            text = "";
            fg = "#c6a0f6";
          }
          {
            name = "Public";
            text = "";
            fg = "#c6a0f6";
          }
          {
            name = "Videos";
            text = "";
            fg = "#c6a0f6";
          }
        ];
        conds = [
          # Special files
          {
            "if" = "orphan";
            text = "";
            fg = "#cad3f5";
          }
          {
            "if" = "link";
            text = "";
            fg = "#a5adcb";
          }
          {
            "if" = "block";
            text = "";
            fg = "#eed49f";
          }
          {
            "if" = "char";
            text = "";
            fg = "#eed49f";
          }
          {
            "if" = "fifo";
            text = "";
            fg = "#eed49f";
          }
          {
            "if" = "sock";
            text = "";
            fg = "#eed49f";
          }
          {
            "if" = "sticky";
            text = "";
            fg = "#eed49f";
          }
          {
            "if" = "dummy";
            text = "";
            fg = "#ed8796";
          }

          # Fallback
          {
            "if" = "dir";
            text = "";
            fg = "#c6a0f6";
          }
          {
            "if" = "exec";
            text = "";
            fg = "#a6da95";
          }
          {
            "if" = "!dir";
            text = "";
            fg = "#cad3f5";
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
