# Base + architecture: vanilla niri + DMS on Silverblue

- **Status:** accepted
- **Created:** 2026-09-02
- **Area:** image (`Containerfile` overall shape + scope)
- **Related:** [Azir](https://github.com/reinier/azir) (the personal image this was split
  out of); [Tashikk](https://github.com/reinier/tashikk) (niri + Noctalia, same additive
  base, but bundles a personal app stack despite its "not personal" framing — see below).

## Decision

Roshar builds **`FROM quay.io/fedora-ostree-desktops/silverblue:44`**, additive: keep GNOME
+ GDM, add **niri + DankMaterialShell** as an alternative session. Unlike Azir (which this
was split out of), Roshar carries none of the personal app stack — no 1Password, Synology
Drive, Tailscale, keyd, or curated CLI toolkit.

## Scope: "bare + strong candidates"

Not literally nothing beyond niri+DMS — a small, deliberately reasoned tier of extras that
are broadly wanted regardless of personal taste, alongside the bare session:

- **Bare session**: niri, DMS, matugen, kitty (default terminal), xwayland-satellite,
  `ddcutil` (a real DMS feature — `dms doctor`'s I2C/DDC brightness check — dead without it).
- **Strong candidates**: Chromium + full codecs, Bazaar (Flatpak app store), a handful of
  broadly-popular CLI tools (`ripgrep`/`fzf`/`bat`/`eza`/`fastfetch`/`btop`/`git-core`/
  `wl-clipboard`), Flathub remote, distrobox.
- **Explicitly excluded**: `fish` as default shell, `starship`/`yazi`/Nerd Font (all three
  need Terra — the first third-party repo Roshar would otherwise avoid), Tailscale — each a
  real product/opinion choice, not a near-universal want the way a browser or app store is.

## Why this isn't extracted from existing precedent

Tashikk's own README claims "provides the desktop and apps, not a personal setup, bring your
own dotfiles" — but its actual `Containerfile` bakes in the same personal app stack as Azir
(1Password, Synology, Tailscale, keyd, wlr-which-key, a curated CLI toolkit). That claim only
ever applied to *config*, never to the *app set*. A prior, separate attempt at a
wider-audience image (`emberdark-os`, archived, one push, June 2026) never got past a title.
Neither is the "vanilla" precedent Roshar is meant to be — this is a new pattern, designed
from Azir's own Containerfile by explicit bucket-by-bucket categorization (generic-niri+DMS
vs. personal-app-choice), not copied from a working example.

## Default config is baked into the image, not `/etc/skel`

DMS (unlike Noctalia, which Tashikk uses) has no built-in configuration fallback — its normal
setup path (`dms setup`) is policy-blocked on atomic systems, and without *some* config it
never even spawns. `/etc/skel` doesn't help here: everyone rebasing onto Roshar already has an
existing user account from before the rebase (skel only seeds accounts at creation time), so
the config is instead baked to `/usr/share/roshar/niri-default-config/` and copied in manually
after first login (see README, and `0004`). The config itself is `dotfiles-azir`'s own
`config.kdl` + `dms/*.kdl` — verified to already be fully generic (no personal content) since
it's exactly what `dms setup` would have generated.

## Deferred: Azir rebuilt `FROM roshar`

The eventual goal — Azir's own `Containerfile` starting `FROM ghcr.io/reinier/roshar:latest`
instead of stock Silverblue directly, dropping everything Roshar now covers — is real but
**not** part of this backlog. Roshar ships and proves itself standalone first; noted as a
forward-looking item in `azir/backlog/README.md` so it isn't lost.

## Verification

Builds green + `bootc container lint`. Rebase from Silverblue; GDM offers GNOME and Niri; the
niri session (after the one manual config-copy step) brings up a working DMS bar/launcher;
GNOME session unaffected. See `0005`.
