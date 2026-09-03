# niri + DMS session (bare core)

- **Status:** done (implemented directly in the initial `Containerfile`)
- **Created:** 2026-09-02
- **Area:** image (`Containerfile`)
- **Depends:** 0000
- **Related:** Azir's own niri+DMS section (`azir/Containerfile:26-81`), copied essentially
  verbatim — same COPR install, same quickshell-provenance guard, same additive checks.

## What

```
dnf5 -y install --setopt=install_weak_deps=False niri xwayland-satellite ddcutil
dnf5 -y install dms matugen
```

- **niri weak-deps-off** — niri Recommends waybar/fuzzel/swaylock/alacritty; DMS provides
  the bar/launcher/lock, so those are excluded.
- **No terminal package installed** — Ptyxis, GNOME's own (`app.devsuite.Ptyxis`), is
  already part of the Silverblue base and Roshar never strips it (see the lean-out note
  below), so `Mod+T` just points at what's already there: `spawn "ptyxis" "--new-window";`.
  **Update (2026-09-03)**: this replaced an earlier version that installed `kitty` — Fedora-
  native too, but an unnecessary second terminal package once it was clear Ptyxis was sitting
  right there unused. `--new-window` matters: Ptyxis is a single-instance GApplication, so a
  bare `ptyxis` would just refocus an existing window instead of opening a fresh one.
- **DMS + quickshell from avengemedia's *stable* COPR** (matched pair — Fedora's DMS 1.4.4 /
  quickshell 0.2.1 are too old for DMS 1.5.x), with the same **quickshell-provenance guard**
  Azir/Steen use: asserts quickshell actually came from the COPR, not Fedora's older build
  (dms's dependency is unversioned, so dnf would silently accept either) — the exact mismatch
  that once crashed Steen's shell.
- **`ddcutil`** — reclassified out of what would otherwise be Azir's CLI-toolkit-only
  territory: it's what makes `dms doctor`'s external-monitor-brightness check possible at
  all, not a personal preference.
- xwayland-satellite drives Xwayland (niri has none built in).

## Guards

Same shape as Azir: quickshell provenance (COPR, not Fedora), niri's GDM session file exists
so "Niri" actually shows up at login, and GNOME/GDM/plumbing all still present (additive —
nothing removed).

## Lean-out: smaller than Azir's

Azir also strips `firefox`/`ptyxis`/`toolbox` — but only because it replaces them with
Chromium/ghostty/distrobox respectively. Roshar doesn't replace ptyxis with anything — it
uses it directly as the niri session's terminal, per the update above — or toolbox, so it
keeps both. What Roshar does strip is minimization that holds regardless of
app choice: onboarding tour/help (`gnome-tour`/`gnome-user-docs`/`yelp`), the interactive
third-party-repo prompt (`fedora-third-party`), hypervisor guest tools (real hardware only),
pre-2010 wifi firmware, `bluez-cups`, `gamemode`.

## Verification (hardware — see 0005)

GDM shows **GNOME** and **Niri**; logging into Niri (after `0004`'s one-time config copy)
brings up niri + DMS (bar, launcher, notifications). GNOME session still works unchanged.
