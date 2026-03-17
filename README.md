# nixos-dotfiles
 
My personal NixOS configuration. GNOME on NixOS stable with flakes, focused on performance and security.
 
<!-- screenshots -->
 ![screenshot](screenshot.png)
---
 
## Stack
 
| | |
|---|---|
| **OS** | NixOS (stable + flakes) |
| **DE** | GNOME + GDM |
| **Kernel** | CachyOS kernel (latest) |
| **Scheduler** | scx_lavd (autopower) |
| **Secure Boot** | lanzaboote |
| **DNS** | NextDNS |
| **Packages** | Nix + Flatpak (Flathub) |
 
---
 
## Structure
 
```
.
├── flake.nix
├── host.nix              # Machine-specific config (copy from host.nix.template)
├── modules/
│   ├── core.nix          # Users, locale, networking, boot
│   ├── desktop.nix       # GNOME, GDM, Flatpak, SCX scheduler
│   ├── hardware.nix      # GPU/CPU drivers, filesystems
│   ├── kernel.nix        # CachyOS kernel + custom kernel config
│   ├── hardening.nix     # Sysctl tweaks, systemd service hardening
│   ├── security.nix      # NextDNS
│   ├── performance.nix   # I/O, CPU tuning
│   └── maintenance.nix   # Auto GC, store optimisation
└── home/
    ├── default.nix
    ├── gnome.nix         # GNOME settings & extensions
    └── packages.nix      # User packages, Flatpaks, MangoHud
```
 
---
 
## Installation
 
A custom ISO is provided that handles installation automatically. **It has not been tested yet — use at your own risk.**
 
If you want to apply the config manually, fill in `host.nix` from the provided template and run:
 
```bash
sudo nixos-rebuild switch --flake .#<hostname>
```
 
---
 
## Notable Features
 
- **CachyOS kernel** with stripped config (unused filesystems, GPUs, network drivers disabled at compile time)
- **Secure Boot** via lanzaboote
- **SCX LAVD scheduler** for better desktop responsiveness and gaming
- **BBR + FQ** TCP congestion control
- **NextDNS** with systemd service hardening
- Dual-boot helper: `winboot` command sets Windows as next boot and reboots
- **MangoHud** pre-configured, toggled with F12
 
---
 
## GNOME Extensions
 
dash-to-panel · arc-menu · blur-my-shell · tiling-shell · user-themes · gsconnect · caffeine · appindicator · just-perfection · quick-settings-audio-panel · clipboard-indicator
 
---
