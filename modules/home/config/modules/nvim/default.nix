{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  nixLinkedPlugins = {
    "AckslD/nvim-neoclip.lua" = {
      package = "nvim-neoclip-lua";
    };
    "kkharji/sqlite.lua" = {
      package = "sqlite-lua";
    };
    "nvim-telescope/telescope.nvim" = {
      package = "telescope-nvim";
    };
    # LazyVim v16 defaults to blink.cmp; the module only tracks it through the
    # coding.blink extra, so it is not in the dev path either.
    "saghen/blink.cmp" = {
      package = "blink-cmp";
    };
    "saghen/blink-copilot" = {
      package = "blink-copilot";
    };
    "catppuccin/nvim" = {
      package = "catppuccin-nvim";
      name = "catppuccin";
    };
    "MeanderingProgrammer/render-markdown.nvim" = {
      package = "render-markdown-nvim";
    };
    "rafamadriz/friendly-snippets" = {
      package = "friendly-snippets";
    };
    # Testcase manager for competitive programming; pulls nui.nvim, which is
    # already linked above.
    "xeluxee/competitest.nvim" = {
      package = "competitest-nvim";
    };
    "ThePrimeagen/harpoon" = {
      package = "harpoon2";
    };
  };

  # Plugins that are not packaged in nixpkgs and come from a flake input
  # instead. All of them are pure Lua, so the checkout is the package and
  # only `dir` has to be set for lazy.nvim to stop trying to install it.
  flakeLinkedPlugins = {
    "07CalC/cook.nvim" = "cook";
  };
in
{
  imports = [ inputs.lazyvim.homeManagerModules.default ];

  programs.lazyvim = {
    enable = true;

    pluginSource = "nixpkgs";

    configFiles = ./src/nvim;

    extras = {
      ai.copilot.enable = true;
      ai.copilot-chat.enable = true;
      lang.markdown.enable = true;
      lang.nix.enable = true;
      # imported here (before user plugins) so LazyVim's import-order check
      # passes; src/nvim/lua/plugins/kulala.lua layers kulala on top by name
      util.rest.enable = true;
    };

    treesitterParsers = with pkgs.vimPlugins.nvim-treesitter-parsers; [
      cmake
      css
      dockerfile
      fish
      git_config
      git_rebase
      gitattributes
      gitcommit
      gitignore
      go
      graphql
      # also highlights kulala's http/rest buffers; kulala cannot install its
      # own parser here, see src/nvim/lua/plugins/kulala.lua
      http
      hyprlang
      java
      # LazyVim core does not ensure it, and runtime :TSInstall is disabled
      # under Nix, so .cpp files would have no parser at all
      cpp
      rasi
      rust
      scss
      sql
    ];

    # Binaries for the LSP servers listed in src/nvim/lua/plugins/lsp.lua.
    # LazyVim only vim.lsp.enable()s servers that appear in its lspconfig
    # opts.servers, and vim.lsp.enable() needs the cmd on $PATH at runtime.
    extraPackages = with pkgs; [
      ansible-language-server
      bash-language-server
      clang-tools
      cmake-language-server
      copilot-language-server
      dockerfile-language-server
      fish-lsp
      # octo.nvim shells out to gh for graphql/pickers
      gh
      # gopls' root_dir detection runs `go env` before starting the server
      go
      gopls
      hyprls
      # jdtls needs a JVM on PATH; the nixpkgs package does not bundle one
      jdk
      jdt-language-server
      lua-language-server
      marksman
      # with prettier and markdownlint-cli2, and nvim-lint lints with
      # markdownlint-cli2 and markdown-toc. Mason is disabled here, so without
      # these they are never installed and conform fails with ENOENT the moment
      # a markdown buffer is formatted.
      markdownlint-cli2
      markdown-toc
      prettier
      nixd
      nixfmt
      pyright
      rust-analyzer
      sqls
      statix
      stylua
      taplo
      typescript-language-server
      # provides cssls, jsonls and html on top of vim's built-in syntax
      vscode-langservers-extracted
      yaml-language-server
      zls
    ];
  };

  xdg.configFile."nvim/lua/theme".source = ./src/nvim/lua/theme;
  # of configFiles, so any other lua/config module needs an explicit link. The
  # same holds for any lua/ file outside lua/plugins — without a link here the
  # activation prune below would delete them from ~/.config/nvim.
  xdg.configFile."nvim/lua/config/terminals.lua".source = ./src/nvim/lua/config/terminals.lua;
  xdg.configFile."nvim/lua/config/runner.lua".source = ./src/nvim/lua/config/runner.lua;
  xdg.configFile."nvim/lua/config/lazy.lua".source = ./src/nvim/lua/config/lazy.lua;
  xdg.configFile."nvim/lua/config/ai-slop.lua".source = ./src/nvim/lua/config/ai-slop.lua;

  home.activation.nvimPruneStaleConfig =
    lib.hm.dag.entryAfter
      [
        "writeBoundary"
      ]
      ''
        if [[ -L "$HOME/.config/nvim/lua/theme.lua" ]]; then
          $DRY_RUN_CMD rm -f "$HOME/.config/nvim/lua/theme.lua"
          echo "removed stale nvim theme.lua (superseded by the theme/ directory)"
        fi
        for dir in "$HOME/.config/nvim/lua" "$HOME/.config/nvim/colors"; do
          [[ -d "$dir" ]] || continue
          # A NUL delimiter keeps the read safe for odd file names, and the
          # $'\\0' form is used because two single quotes in a row would close
          # this Nix indented string.
          while IFS= read -r -d $'\0' f; do
            $DRY_RUN_CMD rm -f "$f"
            echo "removed stale nvim config file: $f"
          done < <(find "$dir" -type f -print0)
        done
      '';

  stylix.targets.neovim.enable = false;

  # Not lib.mkDefault: five other modules define home.packages as a plain list,
  # and mkDefault sits at a lower priority, so the whole list was silently
  # dropped -- stylua and lua-language-server included. List options still merge
  # across modules at equal priority, so a plain definition is what is wanted.
  home.packages = [
    # `oj submit`, reached from <leader>rz. Keeps only a session cookie, never
    # a password; see src/nvim/lua/config/runner.lua.
    pkgs.online-judge-tools
    pkgs.stylua
    pkgs.lua-language-server
    pkgs.sqlite
    # AI-SLOP Detector CLI — runs on BufWritePost via the autocmd in
    # config/ai-slop.lua to produce the lualine AI score + inline warnings.
    pkgs.ai-slop-detector
    # SynthScan CLI — pattern-based AI code detector for C++ files
    # (.cpp/.cc/.h/.hpp/.cxx) where ai-slop-detector lacks parser support.
    pkgs.synthscan
  ];

  xdg.configFile."nvim/lua/config/nix.lua" = {
    text = ''
      -- Generated by modules/home/config/modules/nvim.
      return {
        sqlite_clib = "${lib.getLib pkgs.sqlite}/lib/libsqlite3.so.0";
      }
    '';
  };

  xdg.configFile."nvim/lua/plugins/zz-nixpkgs.lua" = {
    text = ''
      -- Generated by modules/home/config/modules/nvim. Sorted last so it merges
      -- after the hand-written spec files, which only add opts/keys on top of
      -- `dir`.
      return {
      ${lib.concatStringsSep "\n" (
        map (
          repo:
          let
            entry = nixLinkedPlugins.${repo};
            name = lib.optionalString (entry ? name) ", name = \"${entry.name}\"";
          in
          "  { \"${repo}\"${name}, dir = \"${pkgs.vimPlugins.${entry.package}}\" },"
        ) (lib.attrNames nixLinkedPlugins)
      )}
      }
    '';
  };

  xdg.configFile."nvim/lua/plugins/zz-flake.lua" = {
    text = ''
      -- Generated by modules/home/config/modules/nvim. The counterpart of
      -- zz-nixpkgs.lua for plugins that come from a flake input instead of
      -- nixpkgs: nothing but `dir` is set, so the hand-written spec of the
      -- same name still supplies opts/keys.
      return {
      ${lib.concatStringsSep "\n" (
        map (repo: "  { \"${repo}\", dir = \"${inputs.${flakeLinkedPlugins.${repo}}}\" },") (
          lib.attrNames flakeLinkedPlugins
        )
      )}
      }
    '';
  };
}
