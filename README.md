# Roshar

Roshar is a **vanilla** Fedora **[Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/)**-based atomic desktop. It keeps the full GNOME
desktop and adds **[niri](https://github.com/YaLTeR/niri)** — a scrollable-tiling Wayland
compositor — driven by **[DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)**
(bar, launcher, notifications, lock) as an alternative session, picked at the login screen.

**What "atomic" means:** the whole OS is a single image. Updates swap in a new image; if one
breaks, `bootc rollback` returns to the previous one in a single step. Every machine runs the
exact same thing.

**What "vanilla" means:** just niri + DMS + GNOME, plus a small tier of things almost anyone
would want — a friendlier app store, a handful of popular CLI tools. No password manager, no
VPN client, no personal keyboard remaps, no opinionated dotfiles.

## Install

Start from a [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/)
install, then rebase onto Roshar:

```sh
sudo bootc switch ghcr.io/reinier/roshar:latest
sudo systemctl reboot
```

At the GDM login screen, use the session picker (gear icon) to choose **GNOME** or **Niri**.

**Niri sets itself up on first login** — a working config is copied into `~/.config/niri/`
before niri itself even starts (nothing to run yourself), and steps aside entirely if you
already have one there. The bar and launcher (`Mod+Space`) should be up from the very first
login. Personal tweaks go in `~/.config/niri/local.kdl` (optional).

## What you get

On top of everything Silverblue already provides (GNOME, GDM, GNOME Software, PipeWire,
printing, firmware updates, keyring):

- **A second desktop** — niri + DankMaterialShell, with GNOME's own Ptyxis terminal and
  xwayland-satellite for X11 apps.
- **App store** — [Bazaar](https://github.com/kolunmi/Bazaar), a friendlier Flatpak-focused
  alternative to GNOME Software. Installs itself in the background the first time you log in
  with a network connection.
- **CLI tools** — ripgrep, fzf, bat, eza, fastfetch, btop, git, chezmoi; distrobox for
  ad-hoc tooling.
- **Flathub** — pre-added as a remote, ready for `flatpak install`.

## Updating

Two manual streams, nothing unattended:

```sh
sudo bootc upgrade     # the OS image
flatpak update         # your apps
```

`sudo bootc rollback` returns to the previous image.

## Configuration

Roshar provides the desktop and packages, not a personal setup. Bring your own
`~/.config/niri/local.kdl` for keybinds, input tuning, startup apps, and anything else.

## Notes

A personal project, not an official Fedora product — no support, use at your own risk. niri
and DankMaterialShell are independent upstream projects.
