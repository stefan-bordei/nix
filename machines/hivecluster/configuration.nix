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
  boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ];

  # allow unfree
  nixpkgs.config.allowUnfree = true;

  # graphics stuff
  boot.blacklistedKernelModules = [ "nouveau" ];
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
    font = "Lat2-Terminus16";
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
  #services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  #services.printing.enable = true;

  # Enable sound.
  #hardware.pulseaudio.enable = true;
  sound.enable = true;
  security.rtkit.enable = true;
  services.dbus.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # tiling WM
  environment.pathsToLink = [ "/libexec" ];
  services.gnome.gnome-keyring.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
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
