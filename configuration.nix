# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfreePredicate = pkg: true; # nbk unfree
  nixpkgs.config.allowUnfree = true;

  # Bootloader.
  boot.loader.timeout = 20;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "bearrito"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ]; # nbk 
  services.xserver.xkbOptions = "ctrl:nocaps"; # nbk map capslck to control as god intended

  # nbk keyd attempt at control capslock map?
  services.keyd = {
    enable = true;
    keyboards.default.settings = {
      main = {
        capslock = "control";
      };
    };
  };
  # nbk end

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nbk = {
    isNormalUser = true;
    description = "nbk";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      vscode
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # nbk direnv to ensure envrc usage
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  # nbk end

  
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "yourUsernameHere" ];
  };

  # nbk hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      ls = "eza";
      ll = "eza -lh --git";
      la = "eza -lah --git";
      lt = "eza --tree --level=2";
    };
    interactiveShellInit = ''
      if test -f ~/.config/agent-experiment/env
        for line in (grep -v '^\s*#' ~/.config/agent-experiment/env | grep '=')
          set -gx (string split -m 1 '=' $line)
        end
      end
    '';
  };

  environment.sessionVariables = {
    # Core Hyprland/Nvidia Requirements
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";

    # The modern "Ozone" replacement
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  
    # Ensure hardware video acceleration works in browsers
    NVD_BACKEND = "direct"; 
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    pciutils
    jq
    yq
    ripgrep
    fd
    bat
    eza
    fzf
    tree
    just
    httpie
    inxi
    kitty
    wofi
    waybar
    hyprpaper
    starship
    nerd-fonts.jetbrains-mono
    git
    gh
    htop
    nvitop

    config.hardware.nvidia.package.persistenced # nbk: override - shouldn't be needed?

    # --- Configurable Vim ---
    (vim-full.customize {
      name = "vim"; # This ensures you still just type 'vim' to run it
      vimrcConfig.customRC = ''
        " --- Basic Quality of Life ---
        syntax on            " Enable syntax highlighting
        set number           " Show line numbers
        set relativenumber   " Great for jumping lines quickly
        set expandtab        " Use spaces instead of tabs (standard for Python/AI)
        set shiftwidth=2     " Tab size for Nix files
        set softtabstop=2
        set mouse=a          " Enable mouse support
        set clipboard=unnamedplus " Use system clipboard
        
        " --- Search settings ---
        set ignorecase
        set smartcase
        set incsearch
        " --- STOP HITTING THE DAMN F1 KEY INSTEAD OF ESC
        noremap <F1> <Esc>
        inoremap <F1> <Esc>
      '';
      
      # This adds specific plugins managed by Nix
      vimrcConfig.packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ 
          vim-nix      # Better syntax highlighting for .nix files
          nerdtree     # A file explorer (type :NERDTree to open)
          vim-airline  # A nice status bar at the bottom
        ];
      };
    })

    # Base Python Environment
    (python3.withPackages (ps: with ps; [
      pip
      numpy
      pandas
      requests
      tqdm  # Progress bars for model downloads
    ]))
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # nbk nvidia
  hardware.graphics = {
    enable = true;
    # enable32bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = true;
    nvidiaSettings = true;
    nvidiaPersistenced = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # nbk end
 
  # nbk ollama
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    home = "/mnt/ai_mod/ollama";
    group = "ollama";
    user = "ollama";
  };

  # nbk end

  # nbk openwrbui start
  services.open-webui = {
    enable = true;
    port = 8080;
    # This tells the WebUI where to find your Ollama service
    environment = {
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
      # Disables the "New version available" toast since Nix manages updates
      CHECK_UPDATE = "False";
    };
  };
  # Open the port in your firewall so you can access it 
  # (Or just use localhost:8080 if staying on this machine)
  # networking.firewall.allowedTCPPorts = [ 8080 ];
  # nbk end

  services.hardware.bolt.enable = true; # nbk thunderbolt
  boot.loader.systemd-boot.configurationLimit = 8; # nbk limit boot entries
  
  # nbk external drive
  fileSystems."/mnt/ai_mod" = {
    device = "/dev/disk/by-label/AI_MODELS";
    fsType = "ext4";
    options = [ "nofail" "users" "exec" ];
  };
  # nbk end
  
  
  # nbk docker
  virtualisation.docker = {
    enable = true;
    # rootless mode — agent containers shouldn't have root on host
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  # nbk docker end

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
