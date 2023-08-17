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
    ];

  # Bootloader.
  boot.kernelPackages = unstable.linuxPackages_latest;
  boot.initrd.kernelModules = [ "dm_thin_pool" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  boot.extraModprobeConfig = /* modconf */ ''
		options usb-storage quirks=174c:55aa:u
	'';

  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
  };

  boot.loader = {
	grub = {
          efiSupport = true;
          efiInstallAsRemovable = true;
	  memtest86.enable = true;
	};
	efi.canTouchEfiVariables = false;
	systemd-boot = {
	  enable = true;
	  memtest86.enable = true;
	};
  };

  # Setup keyfile
  #boot.initrd.secrets = {
  #  "/crypto_keyfile.bin" = null;
  #};

  # Enable swap on luks
  #boot.initrd.luks.devices."luks-b41cf233-de4e-4634-966c-ba1ae7e8ef3d".device = "/dev/disk/by-uuid/b41cf233-de4e-4634-966c-ba1ae7e8ef3d";
  #boot.initrd.luks.devices."luks-b41cf233-de4e-4634-966c-ba1ae7e8ef3d".keyFile = "/crypto_keyfile.bin";
  
  # mount /data
  fileSystems = {
    "/data" = {
      device = "/dev/disk/by-uuid/15a3428a-1f8f-4833-a155-5f109f32eb08";
      fsType = "ext4";
    };
  };

  boot.supportedFilesystems = [ "ntfs" ];

  # allow unfree
  nixpkgs.config.allowUnfree = true;
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # nvidia
  hardware.nvidia.prime = {
    #open = false;
    #nvidiaSettings = true;
    #package = config.boot.kernelPackages.nvidiaPackages.stable;
    #sync.enable = true;

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";

    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    #intelBusId = "PCI:0:2:0";
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
  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = false;
  #networking.interfaces.wlp2s0.useDHCP = true;

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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # system utilities
    wget
    vim
    gnome.gnome-keyring
    htop
    gitFull
    tmate
    neofetch
    ntfs3g
    firefox

    # gaming
    heroic
    #wine
    #wine64
    lxqt.pavucontrol-qt

    tcpdump
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
  #hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      wireplumber.enable = true;
    };
  #hardware.bluetooth.enable = true;


  # Enable the X11 windowing system.
  #services.xserver.enable = true;
  #services.xserver.layout = "us";
  #services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  #services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  #services.xserver.displayManager.sddm.enable = true;
  #services.xserver.desktopManager.plasma5.enable = true;
  #services.xserver.desktopManager.lxqt.enable = true;
    
  # tiling WM
  environment.pathsToLink = [ "/libexec" ];
  services.gnome.gnome-keyring.enable = true;
  services = {
    # x11
    xserver = {
      enable = true;
      layout = "us";
      
      videoDrivers = [ "nvidia" ];

      deviceSection = ''
        Option "TearFree" "true"
      '';

      config = ''
        Section "Device"
            Identifier "nvidia"
            Driver "nvidia"
            BusID "PCI:1:0:0"
            Option "AllowEmptyInitialConfiguration"
        EndSection
      '';
      screenSection = ''
        Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
        Option         "AllowIndirectGLXProtocol" "off"
        Option         "TripleBuffer" "on"
      '';

      displayManager = {
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
	defaultSession = "xfce+i3";
	#sessionCommands = "${pkgs.xorg.xmodmap}/bin/xmodmap ${myCustomLayout}";
      };

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
	  udiskie
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
    extraGroups = [ "wheel" "audio" "video" "networkmanager" "lxd" "docker" ]; # Enable ‘sudo’ for the user.
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

