{ config, pkgs, libs, ... }:
let
  # bash script to let dbus know about important env variables and
  # propogate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts
  # some user services to make sure they have the correct environment variables
  #dbus-sway-environment = pkgs.writeTextFile {
  #  name = "dbus-sway-environment";
  #  destination = "/bin/dbus-sway-environment";
  #  executable = true;

  #  text = ''
  #    dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
  #    systemctl --user stop pipewire xdg-desktop-portal xdg-desktop-portal-wlr
  #    systemctl --user start pipewire xdg-desktop-portal xdg-desktop-portal-wlr
  #  '';
  #};

  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Materia-dark-compact'
      gsettings set $gnome_schema icon-theme 'Gnome'
      gsettings set $gnome_schema cursor-theme 'Gnome'
      gsettings set $gnome_schema font-name 'Source Sans 10'
    '';
  };
in {
  home.packages = with pkgs; [
    # utilities
    (python3.withPackages(p: with p; [ requests ]))
    asciinema
    htop
    glib # for gsettings
    git-lfs
    gitter
    gnome.gnome-dictionary
    gsimplecal
    keyd
    lazygit
    neovide
    neovim-qt
    nix-info
    nixfmt
    xarchiver
    xdg-utils
    zenmonitor

    # password management
    #keepassxc
    lxqt.lxqt-sudo
    lxqt.lxqt-policykit

    # multimedia
    youtube-dl

    # themes
    adwaita-qt
    numix-gtk-theme
    numix-cursor-theme
    numix-icon-theme
    materia-theme
    libsForQt5.breeze-qt5
    libsForQt5.breeze-gtk
    themechanger

    # graphics
    nomacs
    # messengers
    discord

    # fonts
    go-font
    hack-font
    jetbrains-mono
  ];
}
