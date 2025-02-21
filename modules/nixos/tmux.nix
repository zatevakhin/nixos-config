{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    shortcut = "space";
    clock24 = true;
    baseIndex = 1;
    terminal = "tmux-256color";
    historyLimit = 50000;
    extraConfig = ''
      set -gq allow-passthrough on
      set -g mouse on

      # Vim style pane selection
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Use Alt-arrow keys without prefix key to switch panes
      bind -n M-Left select-pane -L
      bind -n M-Down select-pane -D
      bind -n M-Up select-pane -U
      bind -n M-Right select-pane -R

      # Shift arrow to switch windows
      bind -n S-Left  previous-window
      bind -n S-Right next-window

      # Shift Alt vim keys to switch windows
      bind -n M-H previous-window
      bind -n M-L next-window

      # Open new tmux panes in same directory
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
    '';
    plugins = with pkgs.tmuxPlugins; [
      sensible
      tmux-fzf
      catppuccin
      vim-tmux-navigator
      yank
    ];
  };
}
