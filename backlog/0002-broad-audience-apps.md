# Broad-audience app tier

- **Status:** done
- **Created:** 2026-09-02
- **Area:** image (`Containerfile`) + `files/roshar-install-bazaar` (runtime)
- **Depends:** 0001

## What

Two additions beyond the bare niri+DMS session, chosen for being broadly wanted regardless
of personal taste (see `0000` for the full reasoning on what got included vs. excluded):

1. **A CLI-tools subset**: `ripgrep`, `fzf`, `bat`, `eza`, `fastfetch`, `btop`, `git-core`,
   `wl-clipboard` — cherry-picked out of Azir's fuller toolkit as the part that isn't tied to
   a personal shell/prompt/editor choice (`fish`, `chezmoi`, `xdg-terminal-exec`, `jq`, `zip`,
   `fuse-sshfs` stay Azir-only).
2. **Bazaar** — a friendlier Flatpak app store than GNOME Software
   (`io.github.kolunmi.Bazaar`). **Not an extraction from Azir** — it's not in Azir's image at
   all; reinier installs it personally as a Flatpak via `dotfiles-azir`.

**Update (2026-09-03): Chromium removed.** An earlier version of this item also installed
Chromium + `libavcodec-freeworld` (rpmfusion-free, transiently enabled) for a working browser
out of the box. Dropped in favor of staying closer to vanilla — Firefox is already Silverblue's
own default and needs nothing added, so bundling a second browser wasn't actually necessary to
hit "a working browser exists," just to hit "the specific browser this project's author
personally prefers." Removing it also drops the `rpmfusion-free` repo entirely — nothing else
in Roshar needs it, so this is a net simplification, not just a substitution. Chromium+codecs
stays Azir's own choice, in Azir's own `Containerfile`.

## Bazaar: build-time install replaced with a runtime auto-installer (history)

The first version of this item did `flatpak install --system` at build time. That turned out
to have a real, confirmed-by-research gap, not just a theoretical one: `--system` writes to
`/var/lib/flatpak`, and OSTree only seeds a commit's baked `/var` content into a stateroot on
deployment if that stateroot's `/var` is currently *empty*. `bootc switch` reuses your
existing stateroot — so anyone who'd ever installed a single Flatpak via GNOME Software
*before* switching to Roshar would silently never get Bazaar that way, while CI stayed green
throughout (the build-time guard only ever checked the build layer, not a real deployment).

**Fixed, not just documented as a known issue**: Bazaar is now installed by an
xdg-desktop-autostart entry (`files/roshar-install-bazaar` +
`files/roshar-install-bazaar.desktop`, no `OnlyShowIn` — Bazaar is useful from either session,
and a fresh login may well be GNOME first) that runs `flatpak install --user` if Bazaar isn't
already present in either scope. `--user` scope sidesteps the whole problem: no `/var`, no
stateroot-seeding rule, no root/polkit prompt either. Idempotent and best-effort — no network
on first boot just means it quietly retries on the next login rather than erroring loudly.
Same pattern as the niri config seed (`0004`), and for the same underlying reason: build-time
`/var` writes are the wrong tool for anything that needs to reliably exist after a real
`bootc switch`, not just after a fresh CI build.

## Verification (hardware — see 0005)

`flatpak remotes` shows Flathub. `ripgrep`/`fzf`/`bat`/`eza`/`fastfetch`/`btop` all present on
`$PATH`. Bazaar: log in, wait for network, confirm `flatpak list --user` shows it and it
actually launches — **specifically on a machine that's already had a Flatpak installed before
switching to Roshar**, the exact case that broke the old build-time approach, to confirm the
fix actually holds where the bug did.
