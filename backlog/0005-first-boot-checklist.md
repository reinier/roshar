# First-boot checklist — verify on real hardware

- **Status:** open (living document)
- **Created:** 2026-09-02

CI proves packages resolve and the image lints — not that both sessions come up or DMS
actually gets auto-seeded and spawns, or that Bazaar's build-time Flatpak install actually
produced a launchable app. Rebase a test machine and work top-to-bottom.

```sh
sudo bootc switch ghcr.io/reinier/roshar:latest && sudo systemctl reboot
```

## A. Both sessions

- [ ] GDM offers **GNOME** and **Niri**.
- [ ] **GNOME** session logs in and works normally (additive build didn't disturb it).
- [ ] **Niri** session logs in for the very first time (no `~/.config/niri/` yet). Note
      whether DMS is already up in *this* session or it comes up bare — either is
      acceptable, but which one actually happens needs recording (see `0004`'s open
      question about hot-reload timing).
- [ ] `~/.config/niri/config.kdl` exists after that first login, without you touching
      anything — confirms the autostart entry actually ran.
- [ ] Log out, back into Niri (if the first login was bare): DMS bar + launcher come up.
      `Mod+T` opens Ptyxis. `Mod+Space` opens the DMS launcher.
- [ ] **Bring-your-own-config case**: on a *different* account (or after removing the
      auto-seeded config and dropping in your own `config.kdl` first), log into Niri and
      confirm the autostart entry did nothing — no overwrite, no error.
- [ ] X11 apps run (`pgrep -af xwayland-satellite`).

## B. Zero-dotfiles claim (the actual point of Roshar)

- [ ] On a machine with **no dotfiles applied (chezmoi's binary is present, but pointed at
      nothing), no `dotfiles-azir`, no manual steps at all** — the
      niri+DMS session genuinely works after nothing but logging in. This is the test that
      actually validates "usable by a wider group of users," not just "boots."

## C. Apps

- [ ] Firefox (Silverblue's default) launches fine, untouched.
- [ ] **Bazaar — test on a machine that's already had a Flatpak installed before switching
      to Roshar, not a pristine install.** This is the exact case that broke the original
      build-time approach (see `0002`'s history) — now installed at login via `flatpak
      install --user`, which shouldn't care whether the stateroot's `/var` was already
      non-empty. Confirm `flatpak list --user` shows it after a login or two (needs
      network) and that it actually launches.
- [ ] `flatpak remotes` shows Flathub.
- [ ] `ripgrep`, `fzf`, `bat`, `eza`, `fastfetch`, `btop`, `git`, `chezmoi` all present on
      `$PATH`.
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
