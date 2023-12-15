# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in

{
  imports =
    [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-b41cf233-de4e-4634-966c-ba1ae7e8ef3d".device = "/dev/disk/by-uuid/b41cf233-de4e-4634-966c-ba1ae7e8ef3d";
  boot.initrd.luks.devices."luks-b41cf233-de4e-4634-966c-ba1ae7e8ef3d".keyFile = "/crypto_keyfile.bin";

  # mount /data
  fileSystems = {
    "/data" = {
      device = "/dev/disk/by-uuid/0cc44f5f-9306-491c-ac13-3ce70f169b68";
      fsType = "ext4";
    };
  };

  boot.supportedFilesystems = [ "ntfs" ];

  # allow unfree
  nixpkgs.config.allowUnfree = true;

  # graphics stuff
  #boot.kernelParams = [ "module_blacklist=i915" ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Tablet
  hardware.opentabletdriver.enable = true;

  services.thermald.enable = false;
  hardware.nvidia = {
    nvidiaSettings = true;
    forceFullCompositionPipeline = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      sync = {
        enable = true;
      };
      # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
      nvidiaBusId = "PCI:1:0:0";
      # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
      intelBusId = "PCI:0:2:0";
    };
  };

  # overlays
  #nixpkgs.overlays = [ (import /home/zygot/.config/nixpkgs/overlays/default.nix) ];

  # Enable flakes for home-manager
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Networking
  networking.hostName = "hivecluster"; # Define your hostname.
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
    font = "jetbrains-mono";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "Europe/Dublin";

  # PACKAGES
  #programs.steam.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # system utilities
    wget
    vim
    #gnome.gnome-keyring
    #htop
    #tmux
    #gitFull
    #tmate
    #neofetch
    #ntfs3g

    # home-manager
    home-manager

    # networking
    #unstable.wireshark
    #tcpdump

    # gaming/emulation
    #wine
    #wine64
    #lutris
    #protonup-qt
    #heroic

    #nvidia-offload
    #nitrogen
    #hplip

    #jetbrains-mono
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  #services.printing.enable = true;

  # Enable sound.
  #sound.enable = true;
  hardware.pulseaudio.enable = true;
  sound.enable = true;
  security.rtkit.enable = true;

  # Enable touchpad support.
  #services.xserver.libinput.enable = true;

  # tiling WM
  environment.pathsToLink = [ "/libexec" ];
  services.gnome.gnome-keyring.enable = true;
  services = {
    # x11
    xserver = {
      enable = true;
      layout = "us";
      libinput.enable = true;
      videoDrivers = [ "nvidia" "modesettings" ];

      displayManager = {
        sessionCommands = ''
          ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0
        '';
        defaultSession = "xfce+i3";
        lightdm = {
          enable = true;
          greeters.mini = {
            enable = true;
            user = "zygot";
            extraConfig = ''
              [greeter]
              show-password-label=false
              active-monitor=1
              [greeter-theme]
              background-image = ""
              '';
            };
         };
       };
      #config = ''
      # Section "Device"
      #     Identifier  "Intel Graphics"
      #     Driver      "intel"
      #     #Option      "AccelMethod"  "sna" # default
      #     #Option      "AccelMethod"  "uxa" # fallback
      #     Option      "TearFree"        "true"
      #     Option      "SwapbuffersWait" "true"
      #     BusID       "PCI:0:2:0"
      #     #Option      "DRI" "2"             # DRI3 is now default
      # EndSection

      #Section "Device"
      #     Identifier "nvidia"
      #     Driver "nvidia"
      #     BusID "PCI:1:0:0"
      #     Option "AllowEmptyInitialConfiguration"
      # EndSection
      #'';

      #deviceSection = ''
      #  #Option         "TearFree" "true"
      #  Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      #  Option         "AllowIndirectGLXProtocol" "off"
      #  Option         "TripleBuffer" "on"
      #'';

      desktopManager = {
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
        };
      };

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu #application launcher most people use
          #i3status # gives you the default i3 status bar
          i3lock #default i3 screen locker
          #i3blocks #if you are planning on using i3blocks over i3status
          dunst
          rofi
          rofi-pass
          (polybar.override { i3Support = true; })
          clipmenu
          #udiskie
        ];
      };
    };
  };

  # virtualization
  virtualisation.lxd.enable = true;
  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.zygot = {
    isNormalUser = true;
    extraGroups = [ "nvidia" "wheel" "audio" "video" "networkmanager" "lxd" "docker" ]; # Enable ‘sudo’ for the user.
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
