{ config, pkgs, ... }:
{
  programs.sesh = {
    enable = true;
    package = pkgs.sesh;
    # tmux integration is already wired manually in modules/home/config/modules/tmux/default.nix
    # (sesh picker bindings, last/root, detach-on-destroy). Keep it disabled here to avoid
    # duplicate/conflicting bindings and the fzf tmux shell-integration assertion.
    enableTmuxIntegration = false;
    enableAlias = false;
    settings = {
      # nvim: neovim in the main pane with a small terminal split below (10%).
      # No fixed path so the session is created in whatever directory sesh is
      # invoked from ("current active working dir").
      session = [
        {
          name = "nvim";
          startup_command = "bash -c 'tmux split-window -v -l 10% -c \"#{pane_current_path}\"; exec nvim'";
        }
        {
          name = "downloads";
          path = "~/Downloads";
          startup_command = "yazi";
        }
      ];
    };
  };
}