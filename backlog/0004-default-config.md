# Default niri + DMS config, baked

- **Status:** done
- **Created:** 2026-09-02
- **Area:** image (`files/skel-niri/`) + README
- **Depends:** 0001

## What

`files/skel-niri/` holds a working niri+DMS config, baked into the image at
`/usr/share/roshar/niri-default-config/` (via `COPY` in the `Containerfile`). Sourced from
`dotfiles-azir`'s own `dot_config/niri/config.kdl` + `dms/*.kdl` — verified line-by-line to
already be fully generic (no reinier-specific content: it's literally what `dms setup` would
have generated, vendored in Azir's dotfiles because that setup step is policy-blocked on
atomic systems).

Two changes from a straight copy:

1. **Added `dms/startup.kdl`** — a new file, not present in `dotfiles-azir`'s vendored layer.
   In Azir, `spawn-at-startup "dms" "run"` lives in the *personal* `local/startup.kdl`
   (deliberately, so a global-enabled DMS systemd unit can't leak into the GNOME session —
   see `azir/CLAUDE.md`). Roshar has no personal layer to supply that line, so it's promoted
   into the baked default directly. Without it, the rest of the baked config would still leave
   DMS never launching — a build-time guard checks this file contains the spawn line.
2. **Dropped the personal `local.kdl` include's forced presence.** Azir's `config.kdl` has
   `include "local.kdl"` (non-optional — fine there, since Azir's dotfiles guarantee it
   exists). Roshar's copy uses `include optional=true "local.kdl"` instead, so niri doesn't
   fail to start for a Roshar user who hasn't created one. Also removed one commented-out
   `/-output "eDP-2" { mode "2560x1600@..." }` example block that turned out to be reinier's
   own monitor spec, not a generic example.

## Why not `/etc/skel`

`/etc/skel` only seeds a home directory at *account creation* (`useradd`). Every documented
install path for this project's images (Steen, Tashikk, Azir, and now Roshar) is "start from
a stock Fedora ISO, get a user account there, **then** `bootc switch`" — the account already
exists before Roshar's image ever lands, so `/etc/skel` would never be consulted. Caught
during planning, before implementing it the wrong way.

## What ships instead: a documented one-time copy step

README instructs, after first Niri login:

```sh
mkdir -p ~/.config/niri
cp -r /usr/share/roshar/niri-default-config/* ~/.config/niri/
```

Simple and honest about the `/etc/skel` limitation. A first-boot autostart script that does
this automatically — niri's own vendored config already notes it "supports
xdg-desktop-autostart" — is a reasonable follow-up refinement, not required for a first
working version. Noted as future work, not built here.

## `dank-lader` deliberately not included

Confirmed it's not stock DMS — it's a personal third-party plugin (`lader-dank`, from
reinier's own private Forgejo) symlinked into DMS's plugin directory in `dotfiles-azir`. The
baked `dms/binds.kdl` uses DMS's own stock IPC-call keybinds only (spotlight, clipboard,
powermenu, etc. — already generic as vendored), no leader-menu system assumed.

## Verification (hardware — see 0005)

Fresh Roshar login → Niri session with the copy step done → DMS bar + launcher work, `Mod+T`
opens kitty, `Mod+Space` opens the launcher. Without the copy step, niri should still start
(bare, no bar) rather than fail to launch at all — confirms `optional=true` on `local.kdl`
didn't accidentally make the whole config fragile.
