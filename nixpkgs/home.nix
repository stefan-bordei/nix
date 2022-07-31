{ config, pkgs, nur, ... }: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "zygot";
  home.homeDirectory = "/home/zygot";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    git = {
      enable = true;
      package = pkgs.gitFull;
    };

    #  other programs
    alacritty.enable = true;
    bat.enable = true;
    exa.enable = true;
    firefox.enable = true;
    fzf.enable = true;
    gh.enable = true;
    gitui.enable = true;
    lazygit.enable = true;
    mpv.enable = true;
    neovim.enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    TCLLIBPATH = "$HOME/.local/share/tk-themes";
  };
  services.gnome-keyring.enable = true;
  xdg.enable = true;
}
