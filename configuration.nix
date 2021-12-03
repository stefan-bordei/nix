# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let 
   unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./vim.nix
    ];
  

  # allow unfree
  nixpkgs.config.allowUnfree = true;
  hardware.opengl.driSupport32Bit = true;

  # nvidia
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.prime = {
    sync.enable = true;

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";

    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";
  };  

  # overlays
  nixpkgs.overlays = [ (import /home/zygot/.config/nixpkgs/overlays/default.nix) ];


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 300;

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp3s0.useDHCP = true;
  networking.interfaces.wlp2s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "Europe/Dublin";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # system utilities
    wget
    vim
    htop
    mc
    tmux
    gitFull
    parallel
    zip
    unzip
    p7zip
    tmate
    neofetch
    ntfs3g
    pciutils
    lshw
    lutris

    # apps
    kitty
    neovim
    neovim-qt
    youtube-dl
    nomacs
    mupdf
    zathura
    qpdfview
    llpp
    xdotool
    xclip
    qalculate-gtk
    kate
    unstable.teams
    
    # web
    firefox
    thunderbird
    qbittorrent
    discord
    unstable.zoom-us
    slack
    unstable.skypeforlinux
    #google-chrome
    
    # media
    mpv
    strawberry
    gimp
    
    # desktop themes
    adwaita-qt
    
    # python
    python38
    poppler_utils
    conda
    graphviz
    #jetbrains.pycharm-community
    (python38.withPackages(ps: with ps; [ pynvim virtualenvwrapper 
    					pip jupyterlab pdftotext nltk 
					pyperf pysnmp scapy ]))
    
    # networking
    #unstable.wireshark
    tcpdump

    # containers
    unstable.docker
    unstable.docker-compose

    # java 11
    #unstable.jetbrains.idea-community
    #unstable.jdk11

    # build tools
    unstable.gcc
    unstable.bazel_4
    unstable.qemu
    unstable.nasm

    # music/recording
    #unstable.alsa-lib
    unstable.reaper
    #unstable.ardour
    unstable.guitarix
    #unstable.cadence
    unstable.libjack2
    unstable.jack2
    unstable.qjackctl

    #LV2 plugins
    unstable.glibc
    drumgizmo
    unstable.gxplugins-lv2
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  #services.xserver.desktopManager.lxqt.enable = true;  

  # virtualization
  virtualisation.lxd.enable = true;
  virtualisation.docker.enable = true;

  # audio setup for DAW
  #systemd.user.services.pulseaudio.environment = {
  #  JACK_PROMISCUOUS_SERVER = "jackaudio";
  #};

  #services.jack = {
  #  jackd.enable = true;
  #  # support ALSA only programs via ALSA JACK PCM plugin
  #  alsa.enable = false;
  #  loopback = {
  #    enable = true;
      # buffering parameters for dmix device to work with ALSA only semi-professional sound programs
      #dmixConfig = ''
      #  period_size 2048
      #'';
  #  };
  #};

  # memloc for guitar amp sim
  #security.pam.loginLimits = [
  #  { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
    #{ domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
    #{ domain = "@audio"; item = "nofile"; type = "soft"; value = "99999"; }
    #{ domain = "@audio"; item = "nofile"; type = "hard"; value = "99999"; }
  #];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.zygot = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "networkmanager" "lxd" "docker" "jackaudio" ]; # Enable ‘sudo’ for the user.
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
