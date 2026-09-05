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

## Update (2026-09-05): the sequencing wrinkle below was a real bug, now fixed

Confirmed on real hardware — a clean Silverblue install + `bootc switch` to Roshar came up
with bare niri and no DMS at all, permanently. Root cause, worse than the "hedged" version
below: niri has no fallback for a missing config the way DMS does — if `config.kdl` doesn't
exist when niri starts, niri writes out its *own* embedded stock default and uses that
(documented niri behavior), and that default has no `dms run` spawn line. Once that stock
file exists, the seed script's own idempotency check ("skip if config.kdl already exists")
means it can never self-heal on a later login either. And niri.service's own unit file is
ordered `Wants=`/`Before=xdg-desktop-autostart.target` — niri (and its own stock-config
write, if it wins the race) always starts before the seed script's xdg-autostart entry gets a
chance to run at all.

Fixed with a systemd `--user` unit (`roshar-seed-niri-config.service`, `Before=niri.service`)
plus a drop-in on niri's own packaged `niri.service` (`Requires=`/`After=` the seed unit) —
this actually wins the race, seeding the real config before `niri --session` ever runs. The
xdg-desktop-autostart entry stays too, now genuinely just a harmless no-op fallback (its
exists-check trips immediately since the systemd unit has already done the real work).
README's "log out and back in once if it comes up bare" hedge is removed — first login should
now come up fully configured, no workaround needed. `0005`'s checklist updated to match.

## What ships instead: an xdg-desktop-autostart entry, auto-seeding on first login

Originally shipped as a documented manual copy step (simple, honest about the `/etc/skel`
limitation) — **automated after the fact**, once asked for. niri's own vendored config
already notes it "supports xdg-desktop-autostart", which is exactly the hook needed:

- `files/roshar-seed-niri-config` — a small idempotent script: if
  `~/.config/niri/config.kdl` already exists (the user's own, or ours from a prior login),
  exit immediately; otherwise `cp -rn` the baked tree into `~/.config/niri/`. `-n`
  (no-clobber) is belt-and-braces in case some but not all files already exist.
- `files/roshar-seed-niri-config.desktop` → `/etc/xdg/autostart/`, `OnlyShowIn=niri;` so it
  never runs in the GNOME session, `NoDisplay=true` since it's an implementation detail, not
  a user-facing app.
- Build-time guard confirms the script is present + executable and the `.desktop` entry is
  correctly scoped to niri.

**One real sequencing wrinkle — was not fully resolved here, confirmed as a real bug on real
hardware, now fixed.** See the Update section above: this xdg-desktop-autostart entry alone
fires too late, after niri.service has already started (and, on a truly fresh account,
already written its own stock config with no DMS spawn) — not a hot-reload timing question,
a permanent lock-out. A systemd unit ordered before `niri.service` is what actually closes
the race; this autostart entry remains only as a harmless fallback.

The manual copy command is kept in the README too, as a documented fallback for
troubleshooting — not removed, just no longer the primary path.

## `dank-lader` deliberately not included

Confirmed it's not stock DMS — it's a personal third-party plugin (`lader-dank`, from
reinier's own private Forgejo) symlinked into DMS's plugin directory in `dotfiles-azir`. The
baked `dms/binds.kdl` uses DMS's own stock IPC-call keybinds only (spotlight, clipboard,
powermenu, etc. — already generic as vendored), no leader-menu system assumed.

## Verification (hardware — see 0005)

Fresh Roshar login → Niri session → determine whether DMS bar/launcher appear in the same
session the autostart entry runs in, or only after a second login — document whichever it
turns out to be. Either way, by the second login at the latest: DMS bar + launcher work,
`Mod+T` opens Ptyxis, `Mod+Space` opens the launcher. Bring-your-own-config case: drop a
`config.kdl` in first, confirm the autostart entry does nothing and doesn't clobber it.
