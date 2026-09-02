# First-boot checklist — verify on real hardware

- **Status:** open (living document)
- **Created:** 2026-09-02

CI proves packages resolve and the image lints — not that both sessions come up or DMS
spawns after the config-copy step, or that Bazaar's build-time Flatpak install actually
produced a launchable app. Rebase a test machine and work top-to-bottom.

```sh
sudo bootc switch ghcr.io/reinier/roshar:latest && sudo systemctl reboot
```

## A. Both sessions

- [ ] GDM offers **GNOME** and **Niri**.
- [ ] **GNOME** session logs in and works normally (additive build didn't disturb it).
- [ ] **Niri** session logs in. Before the config-copy step: bare niri, no crash (confirms
      `optional=true "local.kdl"` didn't make the whole config fragile).
- [ ] Run the config-copy step from the README. Log out, back into Niri: DMS bar + launcher
      come up. `Mod+T` opens kitty. `Mod+Space` opens the DMS launcher.
- [ ] X11 apps run (`pgrep -af xwayland-satellite`).

## B. Zero-dotfiles claim (the actual point of Roshar)

- [ ] On a machine with **no chezmoi, no `dotfiles-azir`, nothing beyond the README's
      copy-step** — the niri+DMS session genuinely works. This is the test that actually
      validates "usable by a wider group of users," not just "boots."

## C. Apps

- [ ] Chromium plays H.264 (a known-codec-gated video site, not just that it launches).
- [ ] **Bazaar — test on a machine that's already had a Flatpak installed before switching
      to Roshar, not a pristine install.** `0002` flags a real OSTree gap: baked `/var`
      content (which is where `flatpak install --system` writes) only seeds an *empty*
      stateroot `/var` on deployment — `bootc switch` reuses your existing stateroot, so if
      you'd ever installed so much as one Flatpak via GNOME Software before switching,
      Roshar's baked Bazaar install may silently never appear. CI staying green does NOT
      rule this out (the build-time guard only checks the build layer). If Bazaar is
      missing after switching from an already-used system, that confirms the gap — see
      `0002` for fallback options.
- [ ] `flatpak remotes` shows Flathub.
- [ ] `ripgrep`, `fzf`, `bat`, `eza`, `fastfetch`, `btop`, `git` all present on `$PATH`.
- [ ] `distrobox create` works.

## D. Silverblue plumbing (should be untouched)

- [ ] Audio, WiFi/DNS, Bluetooth, printing (GNOME panel), fingerprint, fwupd.

## E. Updates + trust

- [ ] No OS auto-update timer active; `bootc upgrade` → `rollback` work.
- [ ] Signing: once `SIGNING_SECRET` is set (`0003`), `bootc upgrade` verifies the signature.

## Findings log

| Date | Check | Result | Follow-up |
|---|---|---|---|
| | | | |
