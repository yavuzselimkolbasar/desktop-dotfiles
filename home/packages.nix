{ pkgs, hostConfig, ... }:
{
  # ============================================================
  # Packages
  # ============================================================
  home.packages = with pkgs; [

    # --- GNOME ---
    nautilus
    gnome-tweaks
    gnome-software
    evince
    eog
    gnome-disk-utility
    gnome-text-editor
    gnome-console
    marble-shell-theme
    bibata-cursors

    # --- Gaming ---
    wine
    winetricks
    steam
    steam-rom-manager
    bottles
    steam-run
    freetype
    bubblewrap

    # --- System & CLI Tools ---
    wget
    git
    fastfetch
    libgda6
    gsound
    claude-code

    # --- Media ---
    obs-studio
    easyeffects
    pavucontrol

    # --- Internet ---
    termius
    filezilla

  ] ++ (with pkgs.gnomeExtensions; [
    dash-to-panel
    arc-menu
    user-themes
    gsconnect
    caffeine
    blur-my-shell
    tiling-shell
    appindicator
    just-perfection
    quick-settings-audio-panel
    clipboard-indicator     
  ]);

  # ============================================================
  # Flatpak
  # ============================================================
  services.flatpak = {
    enable = true;

    remotes = [{
      name     = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];

    packages = [
      "org.gnome.Epiphany"
      "com.bitwarden.desktop"
      "com.brave.Browser"
      "com.discordapp.Discord"
      "com.github.tchx84.Flatseal"
      "com.jeffser.Alpaca"
      "com.vscodium.codium"
      "io.ente.auth"
      "io.github.Foldex.AdwSteamGtk"
      "io.github.eminfedar.vaktisalah-gtk-rs"
      "io.github.kolunmi.Bazaar"
      "io.github.sitraorg.sitra"
      "net.davidotek.pupgui2"
      "org.gnome.Totem"
      "org.gnome.font-viewer"
      "org.kde.audiotube"
      "org.prismlauncher.PrismLauncher"
      "org.qbittorrent.qBittorrent"
      "org.vinegarhq.Sober"
      "page.kramo.Cartridges"
    ];
  };

  # ============================================================
  # MangoHud
  # ============================================================
  programs.mangohud = {
    enable            = true;
    enableSessionWide = false;

    settings = {
      fps              = true;
      gpu_stats        = true;
      cpu_stats        = true;
      ram              = true;
      vram             = true;
      gpu_temp         = true;
      cpu_temp         = true;
      frame_timing     = true;
      font_size        = 24;
      background_alpha = 0.4;
      position         = "top-left";
      toggle_hud       = "F12";
    };
  };
}
