# backlog

Build plan for **Roshar** — vanilla niri + DMS on Silverblue, split out of
**[Azir](https://github.com/reinier/azir)** so a working niri+DMS desktop doesn't require
Azir's full personal app/config stack. Azir itself being rebuilt `FROM roshar` is a real goal,
deliberately deferred — see `azir/backlog/README.md`'s forward-looking note.

## The shape (vs Azir)

- **Base:** same additive Silverblue — keep GNOME + GDM, add niri/DMS as a session.
- **App set:** bare niri+DMS core (kitty, `ddcutil`) + a small "strong candidates" tier
  (Chromium+codecs, Bazaar, a CLI-tools subset, Flathub, distrobox) — see `0000` for the full
  include/exclude reasoning. No 1Password, Synology, Tailscale, keyd, or curated CLI toolkit.
- **Config:** unlike Azir (100% BYO-dotfiles), Roshar **bakes a default niri+DMS config into
  the image** (`0004`) — DMS has no built-in fallback, so without this a fresh rebase would
  show a nearly bare niri session.

## Items

0. [0000-base-and-architecture.md](0000-base-and-architecture.md) — decision record: scope,
   why this isn't extracted from existing precedent, the deferred Azir-migration note.
1. [0001-niri-dms-session.md](0001-niri-dms-session.md) — the bare niri+DMS session itself.
2. [0002-broad-audience-apps.md](0002-broad-audience-apps.md) — Chromium, Bazaar, CLI tools.
3. [0003-signing.md](0003-signing.md) — signed update stream (shared key; needs
   `SIGNING_SECRET` on the roshar repo).
4. [0004-default-config.md](0004-default-config.md) — the baked niri+DMS config.
5. [0005-first-boot-checklist.md](0005-first-boot-checklist.md) — living hardware/boot
   verification.

## Deliberately NOT here

1Password, Synology Drive, Tailscale, keyd, `wlr-which-key`/`dank-lader` (no leader-menu
system assumed), `fish`/`starship`/`yazi`/Nerd Font (all personal-shell-adjacent opinions, and
the latter three would need Terra — the first third-party repo beyond avengemedia/rpmfusion
Roshar would otherwise need). All of these are Azir's job, not Roshar's.
