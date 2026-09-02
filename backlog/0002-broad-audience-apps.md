# Broad-audience app tier

- **Status:** implemented, Bazaar unverified
- **Created:** 2026-09-02
- **Area:** image (`Containerfile`)
- **Depends:** 0001

## What

Three additions beyond the bare niri+DMS session, chosen for being broadly wanted regardless
of personal taste (see `0000` for the full reasoning on what got included vs. excluded):

1. **Chromium + `libavcodec-freeworld`** — same as Azir
   (`azir/Containerfile:92-96`, verbatim): rpmfusion-free added, codecs installed, repo file
   removed after. Firefox stays too (additive).
2. **A CLI-tools subset**: `ripgrep`, `fzf`, `bat`, `eza`, `fastfetch`, `btop`, `git-core`,
   `wl-clipboard` — cherry-picked out of Azir's fuller toolkit as the part that isn't tied to
   a personal shell/prompt/editor choice (`fish`, `chezmoi`, `xdg-terminal-exec`, `jq`, `zip`,
   `fuse-sshfs` stay Azir-only).
3. **Bazaar** — a friendlier Flatpak app store than GNOME Software
   (`io.github.kolunmi.Bazaar`). **Not an extraction from Azir** — it's not in Azir's image at
   all; reinier installs it personally as a Flatpak via `dotfiles-azir`. Flathub-only (no
   Fedora RPM), so it's a different install mechanism than everything else in this
   Containerfile:
   ```
   flatpak remote-add --if-not-exists flathub /etc/flatpak/remotes.d/flathub.flatpakrepo
   flatpak install --system --noninteractive flathub io.github.kolunmi.Bazaar
   ```

## Real risk, confirmed by research (not just "untested, hope CI catches it")

`flatpak install --system` writes to `/var/lib/flatpak` — and OSTree treats `/var` specially.
Per OSTree's own docs: on deployment, a commit's baked `/var` content is only seeded into the
**stateroot** if that stateroot's `/var` is currently *empty*. `bootc switch` reuses the
existing stateroot (that's the whole point — your `/home`, existing flatpaks, etc. carry
over). So **the actual failure mode isn't "the build breaks"** — the in-build guard
(`flatpak info --system ...`) checks the build *layer*, which will happily pass, while the
real question is whether `/var/lib/flatpak` on the machine someone is rebasing *from* is
already non-empty (true for essentially anyone who's ever installed a single Flatpak via
GNOME Software on stock Silverblue before switching). If so, Roshar's baked Bazaar install
never gets seeded, and Bazaar silently doesn't exist post-switch — CI stays green throughout.

**This means `0005`'s hardware check has to test the realistic case specifically**: rebase
from an already-used Silverblue install (one that's had at least one flatpak installed
before), not a pristine fresh install, or this gap won't get caught. If it turns out to fail
that way, options: move Bazaar to a first-boot script instead of build-time (loses "just
works after rebase," closer to "gets installed for you once you log in"), or drop it from
Roshar's default set and just recommend it in the README as a one-line `flatpak install`.

## Verification (hardware — see 0005)

Chromium plays H.264. `flatpak remotes` shows Flathub. `flatpak list --system` shows Bazaar,
and it actually launches and can browse/install something. `ripgrep`/`fzf`/`bat`/`eza`/
`fastfetch`/`btop` all present on `$PATH`.
