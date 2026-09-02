# Roshar

Roshar is a **vanilla** Fedora **Silverblue**-based atomic desktop. It keeps the full GNOME
desktop and adds **[niri](https://github.com/YaLTeR/niri)** — a scrollable-tiling Wayland
compositor — driven by **[DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)**
(bar, launcher, notifications, lock) as an alternative session, picked at the login screen.

**What "atomic" means:** the whole OS is a single image. Updates swap in a new image; if one
breaks, `bootc rollback` returns to the previous one in a single step. Every machine runs the
exact same thing.

**What "vanilla" means here:** just niri + DMS + GNOME, plus a small tier of things almost
anyone would want (a real browser, a friendlier app store, a handful of popular CLI tools).
No password manager, no VPN client, no personal keyboard remaps, no curated dotfiles opinion
— those live in [Azir](https://github.com/reinier/azir), the author's personal image built on
the same idea with a full personal app/config layer on top. Roshar exists so that layer isn't
a precondition for a working niri+DMS desktop.

## Install

Start from a [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/)
install, then rebase onto Roshar:

```sh
sudo bootc switch ghcr.io/reinier/roshar:latest
sudo systemctl reboot
```

At the GDM login screen, use the session picker (gear icon) to choose **GNOME** or **Niri**.

**First Niri login sets itself up automatically.** DMS (unlike some other Quickshell-based
shells) has no built-in configuration fallback, and its normal setup command (`dms setup`)
can't run on an atomic system — so a working config is baked into the image and copied into
`~/.config/niri/` for you on first login via a niri session autostart entry (your home
directory already existed before you rebased, so `/etc/skel` can't seed it — this is Roshar's
own equivalent). It only copies if you don't already have a `~/.config/niri/config.kdl` —
bring your own and it steps aside entirely. The very first login may come up bare (niri
starting before the config exists yet); log out and back in once if so, and the bar/launcher
(`Mod+Space`) should be up. Personal tweaks go in `~/.config/niri/local.kdl` (optional —
nothing requires it to exist).

If you ever need to do it by hand (e.g. troubleshooting): the same content lives at
`/usr/share/roshar/niri-default-config/` — `cp -r /usr/share/roshar/niri-default-config/*
~/.config/niri/`.

## What you get

On top of everything Silverblue already provides (GNOME, GDM, GNOME Software, PipeWire,
printing, firmware updates, keyring):

- **A second desktop** — niri + DankMaterialShell, with the kitty terminal and
  xwayland-satellite for X11 apps.
- **Browser** — Chromium with full media codecs (Firefox stays too — additive, not a swap).
- **App store** — [Bazaar](https://github.com/kolunmi/Bazaar), a friendlier Flatpak-focused
  alternative to GNOME Software. Installs itself in the background the first time you log in
  with a network connection (needs one login or two — it's not baked into the image itself).
- **CLI tools** — ripgrep, fzf, bat, eza, fastfetch, btop, git; distrobox for ad-hoc tooling.
- **Flathub** — pre-added as a remote, ready for `flatpak install`.

## Updating

Two manual streams, nothing unattended:

```sh
sudo bootc upgrade     # the OS image
flatpak update         # your apps
```

`sudo bootc rollback` returns to the previous image.

## Configuration

Roshar provides the desktop and packages, not a personal setup — the baked default config
(above) is meant to get you to a *working* desktop, not a *personalized* one. Bring your own
`~/.config/niri/local.kdl` for keybinds, input tuning, startup apps, and anything else.

## Notes

A personal project, not an official Fedora product — the author daily-drives
[Azir](https://github.com/reinier/azir) (built on the same ideas as Roshar, plus a full
personal layer) and treats Roshar as the reusable base underneath it. niri and
DankMaterialShell are independent upstream projects. Named for the planet the author's other
images (Azir, Tashikk — both nations of Roshar in Brandon Sanderson's *Stormlight Archive*)
are named after.
