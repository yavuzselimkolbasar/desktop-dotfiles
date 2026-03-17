{ lib, pkgs, hostConfig, ... }:

let
  inherit (lib.hm.gvariant) mkTuple mkUint32 mkInt32 mkDouble mkVariant;
  pinnedApps = "[{'id': <'org.gnome.Nautilus.desktop'>}, {'id': <'org.gnome.Console.desktop'>}, {'id': <'com.github.tchx84.Flatseal.desktop'>}, {'id': <'termius-app.desktop'>}, {'id': <'com.vscodium.codium.desktop'>}, {'id': <'io.ente.auth.desktop'>}, {'id': <'com.bitwarden.desktop.desktop'>}, {'id': <'com.brave.Browser.desktop'>}, {'id': <'com.discordapp.Discord.desktop'>}, {'id': <'steam.desktop'>}, {'id': <'page.kramo.Cartridges.desktop'>}, {'id': <'io.github.kolunmi.Bazaar.desktop'>}, {'id': <'com.obsproject.Studio.desktop'>}]";
in
{
  systemd.user.services.arcmenu-pinned-apps = {
    Unit = {
      Description = "Restore ArcMenu pinned apps";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = "${pkgs.dconf}/bin/dconf write /org/gnome/shell/extensions/arcmenu/pinned-apps '${pinnedApps}'";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  dconf.settings = {

    # ── Shell ──────────────────────────────────────────────────────────────
    "org/gnome/shell" = {
      disable-user-extensions  = false;
      disabled-extensions      = [];
      enabled-extensions = [
        "dash-to-panel@jderose9.github.com"
        "arcmenu@arcmenu.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "gsconnect@andyholmes.github.io"
        "caffeine@patapon.info"
        "blur-my-shell@aunetx"
        "tilingshell@ferrarodomenico.com"
        "appindicatorsupport@rgcjonas.gmail.com"
        "just-perfection-desktop@just-perfection"
        "quick-settings-audio-panel@rayzeq.github.io"
        "clipboard-indicator@tudmotu.com"
      ];
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "com.brave.Browser.desktop"
        "com.discordapp.Discord.desktop"
        "org.kde.audiotube.desktop"
        "page.kramo.Cartridges.desktop"
      ];
      last-selected-power-profile = "performance";
    };

    "org/gnome/shell/app-switcher" = {
      current-workspace-only = false;
    };

    # ── Interface ──────────────────────────────────────────────────────────
    "org/gnome/desktop/interface" = {
      clock-format             = "12h";
      clock-show-weekday       = true;
      color-scheme             = "prefer-dark";
      document-font-name       = "Inter Italic 12";
      enable-animations        = true;
      enable-hot-corners       = false;
      font-name                = "Inter Italic 11";
      gtk-enable-primary-paste = false;
      gtk-theme                = "adw-gtk3-dark";
      icon-theme               = "Colloid-Dark";
    };

    # ── Background ─────────────────────────────────────────────────────────
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options    = "zoom";
      picture-uri        = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      picture-uri-dark   = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
      primary-color      = "#241f31";
      secondary-color    = "#000000";
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options    = "zoom";
      picture-uri        = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      primary-color      = "#241f31";
      secondary-color    = "#000000";
    };

    # ── Window Manager ─────────────────────────────────────────────────────
    "org/gnome/desktop/wm/preferences" = {
      button-layout         = "appmenu:minimize,maximize,close";
      focus-mode            = "mouse";
      mouse-button-modifier = "<Alt>";
      num-workspaces        = 4;
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = false;
      center-new-windows   = true;
      dynamic-workspaces   = false;
      edge-tiling          = false;
      overlay-key          = "Super_L";
    };

    # ── Keybindings: Window Manager ────────────────────────────────────────
    "org/gnome/desktop/wm/keybindings" = {
      close                        = [ "<Super>q" ];
      cycle-group                  = [ "<Control><Super>Tab" ];
      cycle-group-backward         = [ "<Shift><Control><Super>Tab" ];
      cycle-panels                 = [ "@as []" ];
      cycle-panels-backward        = [ "@as []" ];
      cycle-windows                = [ "<Super>Tab" ];
      cycle-windows-backward       = [ "<Shift><Super>Tab" ];
      maximize                     = [ "@as []" ]; 
      minimize                     = [ "@as []" ];
      move-to-monitor-down         = [ "@as []" ];
      move-to-monitor-left         = [ "@as []" ];
      move-to-monitor-right        = [ "@as []" ];
      move-to-monitor-up           = [ "@as []" ];
      move-to-workspace-1          = [ "<Shift><Super>1" ];
      move-to-workspace-2          = [ "<Shift><Super>2" ];
      move-to-workspace-3          = [ "<Shift><Super>3" ];
      move-to-workspace-4          = [ "<Shift><Super>4" ];
      move-to-workspace-last       = [ "@as []" ];
      move-to-workspace-left       = [ "@as []" ];
      move-to-workspace-right      = [ "@as []" ];
      panel-run-dialog             = [ "@as []" ];
      switch-applications          = [ "@as []" ];
      switch-applications-backward = [ "@as []" ];
      switch-group                 = [ "<Control><Alt>Tab" ];
      switch-group-backward        = [ "<Shift><Control><Alt>Tab" ];
      switch-input-source          = [ "<Super>space" ];
      switch-input-source-backward = [ "<Shift><Super>space" ];
      switch-panels                = [ "@as []" ];
      switch-panels-backward       = [ "@as []" ];
      switch-to-workspace-1        = [ "<Super>1" ];
      switch-to-workspace-2        = [ "<Super>2" ];
      switch-to-workspace-3        = [ "<Super>3" ];
      switch-to-workspace-4        = [ "<Super>4" ];
      switch-to-workspace-last     = [ "@as []" ];
      switch-to-workspace-left     = [ "@as []" ];
      switch-to-workspace-right    = [ "@as []" ];
      switch-windows               = [ "<Alt>Tab" ];
      switch-windows-backward      = [ "<Shift><Alt>Tab" ];
      unmaximize                   = [ "@as []" ]; 
    };

    # ── Keybindings: ────────────────────────────────────────────────
    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left  = [ "@as []" ];
      toggle-tiled-right = [ "@as []" ];
    };

    "org/gnome/mutter/wayland/keybindings" = {
      restore-shortcuts = [ "@as []" ];
    };
    
    "org/gnome/shell/keybindings" = {
      focus-active-notification = [ "@as []" ];
      screenshot                = [ "Print" ];
      show-screen-recording-ui  = [ "<Super>r" ];
      show-screenshot-ui        = [ "<Shift><Super>s" ];
      switch-to-application-1   = [ "@as []" ];
      switch-to-application-2   = [ "@as []" ];
      switch-to-application-3   = [ "@as []" ];
      switch-to-application-4   = [ "@as []" ];
      toggle-application-view   = [ "@as []" ];
      toggle-message-tray       = [ "@as []" ];
      toggle-quick-settings     = [ "@as []" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
      ];
      help               = [ "@as []" ];
      logout             = [ "@as []" ];
      magnifier          = [ "@as []" ];
      magnifier-zoom-in  = [ "@as []" ];
      magnifier-zoom-out = [ "@as []" ];
      mic-mute           = [ "<Super>AudioMute" ];
      next               = [ "AudioNext" ];
      play               = [ "AudioPlay" ];
      previous           = [ "AudioPrev" ];
      screenreader       = [ "@as []" ];
      search             = [ "<Alt>q" ];
      shutdown           = [ "@as []" ];
      www                = [ "<Super>b" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>t";
      command = "kgx";
      name    = "Terminal";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Super>e";
      command = "nautilus";
      name    = "File Manager";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Control><Alt>w";
      command = "pkexec winboot";
      name    = "Winboot";
    };

    # ── Input ──────────────────────────────────────────────────────────────
    "org/gnome/desktop/input-sources" = {
      sources     = [ (mkTuple [ "xkb" "us" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" "lv3:ralt_switch" ];
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
      double-click  = 357;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    # ── Power ────────────────────────────────────────────────────
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 900;
    };

    # ── Privacy ────────────────────────────────────────────────────────────
    "org/gnome/desktop/privacy" = {
      disable-camera         = true;
      recent-files-max-age   = 30;
      remove-old-temp-files  = true;
      remove-old-trash-files = true;
    };

    # ── Night Light ────────────────────────────────────────────────────────
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled            = true;
      night-light-schedule-automatic = false;
    };

    # ── Break Reminders ────────────────────────────────────────────────────
    "org/gnome/desktop/break-reminders/eyesight" = {
      play-sound = true;
    };

    "org/gnome/desktop/break-reminders/movement" = {
      duration-seconds = mkUint32 300;
      interval-seconds = mkUint32 1800;
      play-sound       = true;
    };

    # ── Search ─────────────────────────────────────────────────────────────
    "org/gnome/desktop/search-providers" = {
      disabled   = [ "org.gnome.Settings.desktop" "org.gnome.Software.desktop" ];
      enabled    = [
        "com.jeffser.Alpaca.desktop"
        "io.github.kolunmi.Bazaar.desktop"
        "page.kramo.Cartridges.desktop"
      ];
      sort-order = [
        "org.gnome.Settings.desktop"
        "org.gnome.Contacts.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };

    # ── Nautilus ───────────────────────────────────────────────────────────
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
    };

    # ── App Folders ────────────────────────────────────────────────────────
    "org/gnome/desktop/app-folders" = {
      folder-children = [ "System" "Utilities" "YaST" "Pardus" ];
    };

    "org/gnome/desktop/app-folders/folders/System" = {
      apps      = [ "org.gnome.DiskUtility.desktop" "org.gnome.tweaks.desktop" ];
      name      = "X-GNOME-Shell-System.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps      = [ "org.gnome.font-viewer.desktop" ];
      name      = "X-GNOME-Shell-Utilities.directory";
      translate = true;
    };

    # ── GTK File Chooser ───────────────────────────────────────────────────
    "org/gtk/gtk4/settings/file-chooser" = {
      date-format            = "regular";
      location-mode          = "path-bar";
      show-hidden            = false;
      sidebar-width          = 140;
      sort-column            = "name";
      sort-directories-first = true;
      sort-order             = "ascending";
      type-format            = "category";
      view-type              = "list";
    };

    "org/gtk/settings/file-chooser" = {
      clock-format = "12h";
    };

    # ══════════════════════════════════════════════════════════════════════
    # Extension Settings
    # ══════════════════════════════════════════════════════════════════════

    # ── User Theme ─────────────────────────────────────────────────────────
    "org/gnome/shell/extensions/user-theme" = {
      name = "Marble-blue-dark";
    };

    # ── Caffeine ───────────────────────────────────────────────────────────
    "org/gnome/shell/extensions/caffeine" = {
      cli-toggle             = false;
      indicator-position-max = 1;
      show-indicator         = "never";
      show-notifications     = false;
    };

    # ── Clipboard Indicator ────────────────────────────────────────────────
    "org/gnome/shell/extensions/clipboard-indicator" = {
      excluded-apps = [ "Bitwarden" ];
      toggle-menu   = [ "<Super>v" ];
    };

    # ── Blur My Shell ──────────────────────────────────────────────────────
    "org/gnome/shell/extensions/blur-my-shell" = {
      settings-version = 2;
    };

    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      brightness = 0.6;
      sigma      = 30;
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      brightness                      = 0.6;
      override-background-dynamically = true;
      pipeline                        = "pipeline_default";
      sigma                           = 30;
      static-blur                     = false;
    };

    # ── GSConnect ──────────────────────────────────────────────────────────
    "org/gnome/shell/extensions/gsconnect" = {
      missing-openssl = false;
      name            = hostConfig.hostname;
    };

    # ── Just Perfection ────────────────────────────────────────────────────
    "org/gnome/shell/extensions/just-perfection" = {
      support-notifier-type = 0;
    };

    # ── Quick Settings Audio Panel ─────────────────────────────────────────
    "org/gnome/shell/extensions/libpanel" = {
      layout = [ [ "quick-settings-audio-panel@rayzeq.github.io/main" "gnome@main" ] ];
    };

    "org/gnome/shell/extensions/quick-settings-audio-panel" = {
      version = 2;
    };

    # ── Dash to Panel ──────────────────────────────────────────────────────
    "org/gnome/shell/extensions/dash-to-panel" = {
      animate-appicon-hover                = true;
      animate-appicon-hover-animation-type = "SIMPLE";
      appicon-margin                       = 4;
      appicon-padding                      = 3;
      dot-position                         = "BOTTOM";
      dot-style-focused                    = "DASHES";
      dot-style-unfocused                  = "SQUARES";
      hotkeys-overlay-combo                = "TEMPORARILY";
      multi-monitors                       = false;
      panel-side-margins                   = 0;
      progress-show-count                  = true;
      scroll-icon-action                   = "NOTHING";
      scroll-panel-action                  = "NOTHING";
      secondarymenu-contains-showdetails   = true;
      show-apps-icon-file                  = "";
      show-apps-override-escape            = false;
      show-favorites                       = true;
      show-window-previews-timeout         = 150;
      trans-dynamic-anim-target            = 0.5;
      trans-dynamic-behavior               = "FOCUSED_WINDOWS";
      trans-panel-opacity                  = 0.3;
      trans-use-custom-opacity             = true;
      trans-use-dynamic-opacity            = true;
      window-preview-animation-time        = 100;
      window-preview-title-position        = "TOP";
      panel-anchors           = ''{"GSM-309NTWG6J321":"MIDDLE","LEN-URHK8GKL":"MIDDLE"}'';
      panel-positions         = ''{"GSM-309NTWG6J321":"BOTTOM","LEN-URHK8GKL":"BOTTOM"}'';
      panel-element-positions = ''{"GSM-309NTWG6J321":[{"element":"showAppsButton","visible":false,"position":"centered"},{"element":"activitiesButton","visible":false,"position":"centered"},{"element":"leftBox","visible":true,"position":"centerMonitor"},{"element":"taskbar","visible":true,"position":"centerMonitor"},{"element":"centerBox","visible":true,"position":"centerMonitor"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}],"LEN-URHK8GKL":[{"element":"showAppsButton","visible":false,"position":"centered"},{"element":"activitiesButton","visible":false,"position":"centered"},{"element":"leftBox","visible":true,"position":"centerMonitor"},{"element":"taskbar","visible":true,"position":"centerMonitor"},{"element":"centerBox","visible":true,"position":"centerMonitor"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}]}'';
    };

    "org/gnome/shell/extensions/arcmenu" = {
      arcmenu-hotkey                     = [ "Super_L" ];
      arcmenu-hotkey-overlay-key-enabled = true;
      custom-menu-button-icon-size       = 35.0;
      dash-to-panel-standalone           = false;
      distro-icon                        = 22;
      eleven-disable-frequent-apps       = true;
      force-menu-location                = "BottomCentered";
      hotkey-open-primary-monitor        = true;
      left-panel-width                   = 290;
      menu-button-icon                   = "Distro_Icon";
      menu-button-middle-click-action    = "None";
      menu-button-right-click-action     = "ContextMenu";
      menu-height                        = 550;
      menu-item-category-icon-size       = "Medium";
      menu-item-grid-icon-size           = "Medium";
      menu-item-icon-size                = "Medium";
      menu-layout                        = "AZ";
      menu-position-alignment            = 0;
      menu-width-adjustment              = 75;
      misc-item-icon-size                = "Default";
      multi-monitor                      = false;
      position-in-panel                  = "Left";
      quicklinks-item-icon-size          = "Medium";
      right-panel-width                  = 205;
      show-activities-button             = false;
      show-category-sub-menus            = false;
      update-notifier-project-version    = 69;
    };

    # ── Tiling Shell ───────────────────────────────────────────────────────
    "org/gnome/shell/extensions/tilingshell" = {
      edge-tiling-mode                 = "default";
      edge-tiling-offset               = mkUint32 50;
      enable-blur-selected-tilepreview = true;
      enable-blur-snap-assistant       = true;
      inner-gaps                       = mkUint32 0;
      outer-gaps                       = mkUint32 0;
      quarter-tiling-threshold         = mkUint32 30;
      show-indicator                   = false;
      snap-assist-sync-layout          = true;
      window-use-custom-border-color   = false;
      selected-layouts                 = [ [ "Layout 1" "Layout 1" ] [ "Layout 1" "Layout 1" ] ];
      layouts-json = ''[{"id":"Layout 1","tiles":[{"x":0,"y":0,"width":0.50625,"height":1,"groups":[1]},{"x":0.50625,"y":0,"width":0.49375,"height":1,"groups":[1]}]},{"id":"696433","tiles":[{"x":0,"y":0,"width":0.49375,"height":1,"groups":[1]},{"x":0.49375,"y":0,"width":0.5062499999999999,"height":0.5,"groups":[2,1]},{"x":0.49375,"y":0.5,"width":0.5062499999999999,"height":0.4999999999999999,"groups":[2,1]}]},{"id":"746584","tiles":[{"x":0,"y":0,"width":0.5,"height":0.5,"groups":[1,2]},{"x":0.5,"y":0,"width":0.5000000000000006,"height":0.5,"groups":[3,1]},{"x":0,"y":0.5,"width":0.5,"height":0.5,"groups":[2,1]},{"x":0.5,"y":0.5,"width":0.5000000000000006,"height":0.5,"groups":[3,1]}]}]'';
    };

  };
}
