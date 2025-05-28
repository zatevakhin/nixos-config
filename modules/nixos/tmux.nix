{pkgs, ...}: let
  rusmux = pkgs.callPackage ../packages/rusmux {};
in {
  environment.systemPackages = [
    rusmux
  ];

  programs.tmux = {
    enable = true;
    shortcut = "space";
    clock24 = true;
    baseIndex = 1;
    terminal = "tmux-256color";
    historyLimit = 50000;
    extraConfig = ''
      set -gq set-clipboard on
      set -gq allow-passthrough on
      set -gq mouse on

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

      # set vi-mode
      set-window-option -g mode-keys vi

      # keybindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Open new tmux panes in same directory
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      set -g @catppuccin_flavor "mocha"                # latte, frappe, macchiato or mocha
      set -g @catppuccin_window_status_style "slanted" # basic, rounded, slanted or none
      set -g status-right-length 100
      set -g status-left-length 100
      set -g status-left ""
      set -g status-right "#{E:@catppuccin_status_application}"
      set -ag status-right "#{E:@catppuccin_status_session}"
      set -ag status-right "#{E:@catppuccin_status_uptime}"
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
