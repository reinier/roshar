# Roshar — vanilla Fedora Silverblue + niri + DankMaterialShell (DMS), GNOME kept.
#
# Roshar is the "bare" counterpart to Azir: the same additive Silverblue base (keep the
# full GNOME desktop + GDM, add niri + DMS as an alternative session), but with none of
# Azir's personal app stack (1Password, Synology Drive, Tailscale, keyd, a curated CLI
# toolkit, ghostty). Just niri+DMS itself, a default terminal, and a small tier of
# broadly-useful extras (a real browser, a nicer app store, a handful of popular CLI
# tools) that don't amount to a personal opinion the way those do.
#
# Meant to be rebased onto by anyone, and (eventually — not yet) the base Azir itself
# builds FROM instead of stock Silverblue directly.

# Silverblue base — the full GNOME atomic desktop. GNOME stays; GDM stays (it gains a
# "Niri" session entry once niri is installed below).
FROM quay.io/fedora-ostree-desktops/silverblue:44

# --- niri + DankMaterialShell session (added alongside GNOME) ---
# niri Recommends waybar/fuzzel/swaylock/alacritty — install with weak deps OFF so those
# don't come along (DMS provides bar/launcher/lock; GNOME provides the rest). niri's wanted
# recommends (gnome-keyring, wireplumber, portals) are already present from Silverblue.
# niri has NO built-in Xwayland, so xwayland-satellite drives the base's Xwayland server.
# kitty is the session's default terminal — Fedora-native (no extra repo needed), matching
# what the baked niri config's DMS keybinds spawn (Mod+T).
#
# DMS + quickshell + dms-cli as a MATCHED PAIR from upstream's *stable* COPRs — Fedora's DMS
# 1.4.4 / quickshell 0.2.1 are too old for DMS 1.5.x. matugen (DMS theming) from Fedora.
# ddcutil: DMS's own `dms doctor` checks for I2C/DDC support for external-monitor
# brightness control; without it that DMS feature can never activate for anyone.
COPY files/avengemedia-dms.repo files/avengemedia-danklinux.repo /etc/yum.repos.d/
RUN dnf5 -y install --setopt=install_weak_deps=False \
      niri kitty xwayland-satellite ddcutil \
 && dnf5 -y install dms matugen \
 && rm -f /etc/yum.repos.d/avengemedia-dms.repo \
          /etc/yum.repos.d/avengemedia-danklinux.repo \
 && dnf5 clean all

# Guard: assert quickshell PROVENANCE, not versions. dms's dependency is the unversioned
# `(quickshell or quickshell-git)`, so rpm is equally satisfied by Fedora's much older
# quickshell — it only resolves to the COPR build because that repo is enabled and dnf takes
# the highest version. A silently mismatched quickshell crashed the shell on Steen once.
RUN set -e; \
    rpm -q niri kitty xwayland-satellite ddcutil dms dms-cli quickshell matugen >/dev/null; \
    ! rpm -q DankMaterialShell >/dev/null 2>&1 \
      || { echo "ERROR: Fedora's DankMaterialShell is installed alongside COPR dms" >&2; exit 1; }; \
    command -v niri >/dev/null || { echo "ERROR: niri binary missing" >&2; exit 1; }; \
    command -v dms  >/dev/null || { echo "ERROR: dms CLI missing" >&2; exit 1; }; \
    qs_repo="$(dnf5 repoquery --installed --qf '%{from_repo}' quickshell | head -1)"; \
    case "$qs_repo" in \
      *avengemedia*) ;; \
      *) echo "ERROR: quickshell came from '${qs_repo}', not the avengemedia COPR." >&2; exit 1;; \
    esac; \
    echo "desktop core: niri $(rpm -q --qf '%{VERSION}' niri), dms $(rpm -q --qf '%{VERSION}' dms), quickshell $(rpm -q --qf '%{VERSION}' quickshell) [${qs_repo}]"

# SwayNotificationCenter can leak in as a weak dep of the dms/niri COPR stack (dms is
# installed weak-deps-ON for matugen/cava); DMS provides notifications, so purge it.
RUN rpm -q SwayNotificationCenter >/dev/null 2>&1 && dnf5 -y remove SwayNotificationCenter || true \
 && dnf5 clean all

# Additive guard: the niri/DMS session landed AND GNOME/GDM/plumbing survived (nothing should
# be removed on an additive build). Also assert niri ships its GDM session file so the "Niri"
# entry appears at login.
RUN set -e; \
    test -f /usr/share/wayland-sessions/niri.desktop \
      || { echo "ERROR: niri GDM session file missing — GDM won't offer a Niri session; bake one" >&2; exit 1; }; \
    rpm -q gnome-shell gdm xdg-desktop-portal-gnome gnome-keyring \
           pipewire wireplumber NetworkManager >/dev/null \
      || { echo "ERROR: GNOME/plumbing was disturbed by the niri layer (should be additive)" >&2; exit 1; }; \
    ! rpm -q sddm >/dev/null 2>&1 || { echo "ERROR: sddm present — GDM should be the only DM" >&2; exit 1; }; \
    echo "session OK: niri + dms + kitty added; GNOME/GDM intact"

# --- Default niri+DMS config, baked in + auto-seeded on first login (see backlog/0004) ---
# `dms setup` (what would normally generate this) is policy-blocked on ostree/atomic, and
# DMS has no built-in fallback the way some shells do — without a config it simply never
# spawns. /etc/skel doesn't help here: everyone rebasing onto Roshar already has an existing
# user account from before the rebase (skel only seeds NEW accounts). Instead: the config is
# baked to a fixed path, and an xdg-desktop-autostart entry (niri's own vendored config notes
# it supports this) copies it into ~/.config/niri on first Niri login, idempotently — gets
# out of the way immediately if the user already has their own config.kdl.
COPY files/skel-niri/ /usr/share/roshar/niri-default-config/
COPY files/roshar-seed-niri-config /usr/libexec/roshar-seed-niri-config
COPY files/roshar-seed-niri-config.desktop /etc/xdg/autostart/roshar-seed-niri-config.desktop
RUN chmod 0755 /usr/libexec/roshar-seed-niri-config; \
    test -f /usr/share/roshar/niri-default-config/config.kdl \
      || { echo "ERROR: default niri config missing from the image" >&2; exit 1; }; \
    grep -q 'spawn-at-startup "dms" "run"' \
         /usr/share/roshar/niri-default-config/dms/startup.kdl \
      || { echo "ERROR: default config won't actually launch DMS" >&2; exit 1; }; \
    test -x /usr/libexec/roshar-seed-niri-config \
      || { echo "ERROR: config-seed script missing or not executable" >&2; exit 1; }; \
    grep -q 'OnlyShowIn=niri;' /etc/xdg/autostart/roshar-seed-niri-config.desktop \
      || { echo "ERROR: config-seed autostart entry not scoped to the niri session" >&2; exit 1; }; \
    echo "default niri+DMS config baked + auto-seed autostart entry in place"

# --- Native Chromium + free codecs ---
# A working-out-of-the-box browser is close to a universal want; Silverblue's stock Firefox
# lacks H.264/AAC without user action. Firefox is left in place (additive, not a swap).
RUN dnf5 -y install "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
 && dnf5 -y install chromium libavcodec-freeworld \
 && rm -f /etc/yum.repos.d/rpmfusion-*.repo \
 && dnf5 clean all

# --- A handful of broadly-popular CLI tools ---
# Cherry-picked from Azir's fuller CLI toolkit: the subset that isn't tied to a personal
# shell/prompt/editor choice (fish, chezmoi, xdg-terminal-exec, jq, zip, fuse-sshfs stay
# Azir-only). wl-clipboard: general Wayland clipboard utility scripts commonly assume exists.
RUN dnf5 -y install ripgrep fzf bat eza fastfetch btop git-core wl-clipboard \
 && dnf5 clean all

# --- Flathub remote ---
# Via /etc/flatpak/remotes.d so it ships in the image (flatpak remote-add writes to
# machine-local /var). GNOME Software (Silverblue OOTB) is the flatpak store.
RUN mkdir -p /etc/flatpak/remotes.d \
 && curl -fsSL -o /etc/flatpak/remotes.d/flathub.flatpakrepo \
      https://dl.flathub.org/repo/flathub.flatpakrepo

# --- Bazaar: a friendlier Flatpak app store than GNOME Software ---
# Flathub-only (no Fedora RPM), so this is a different mechanism than everything else in
# this file: a build-time system-wide Flatpak install instead of dnf5. Needs the Flathub
# remote above already in place. This pattern is untested in this project's own
# Containerfiles before now — if it doesn't work cleanly in CI, this block is the first
# place to look (see backlog/0002).
RUN flatpak remote-add --if-not-exists flathub /etc/flatpak/remotes.d/flathub.flatpakrepo \
 && flatpak install --system --noninteractive flathub io.github.kolunmi.Bazaar

# --- Dev containers ---
# distrobox is the ad-hoc CLI-tooling path (no Homebrew). Silverblue ships toolbox + podman
# but not distrobox.
RUN dnf5 -y install distrobox \
 && dnf5 clean all

# --- Lean out: strip Silverblue defaults not tied to any app choice above ---
# Deliberately smaller than Azir's own strip list: Azir also removes firefox/ptyxis/toolbox,
# but only because it replaces them with Chromium/ghostty/distrobox respectively — Roshar
# doesn't replace ptyxis or toolbox with anything, so leaves them. What's left here is
# minimization that holds regardless of which browser/terminal/container tool a user prefers.
#   gnome-tour, gnome-user-docs, yelp — first-run OOBE tour + GNOME's help browser and
#     its docs; pure onboarding/reference, no functional loss.
#   fedora-third-party — the "enable third-party repos" prompt; repos are managed
#     explicitly in this Containerfile, not interactively.
#   open-vm-tools-desktop, virtualbox-guest-additions, qemu-guest-agent,
#     hyperv-daemons — hypervisor guest-integration tools; Roshar targets real hardware.
#   b43-fwcutter, b43-openfwwf, iwlegacy-firmware — firmware for wifi chips
#     discontinued before ~2010.
#   bluez-cups — Bluetooth printing, essentially unused.
#   gamemode — game-performance daemon; no game launchers baked in here.
RUN dnf5 -y remove \
      gnome-tour gnome-user-docs yelp fedora-third-party \
      open-vm-tools-desktop virtualbox-guest-additions qemu-guest-agent hyperv-daemons \
      b43-fwcutter b43-openfwwf iwlegacy-firmware bluez-cups gamemode \
 && dnf5 clean all

# Guard: confirm the stripped packages are actually gone and GNOME/GDM survived.
RUN set -e; \
    for pkg in gnome-tour gnome-user-docs yelp fedora-third-party open-vm-tools-desktop \
               virtualbox-guest-additions qemu-guest-agent hyperv-daemons \
               b43-fwcutter b43-openfwwf iwlegacy-firmware bluez-cups gamemode; do \
      ! rpm -q "$pkg" >/dev/null 2>&1 || { echo "ERROR: $pkg still installed after strip" >&2; exit 1; }; \
    done; \
    rpm -q gnome-shell gdm xdg-desktop-portal-gnome gnome-keyring \
           pipewire wireplumber NetworkManager >/dev/null \
      || { echo "ERROR: the strip disturbed GNOME/plumbing (should only remove the named leaves)" >&2; exit 1; }; \
    echo "lean-out OK: 12 packages stripped, GNOME/GDM intact"

# Guard for the whole app layer.
RUN set -e; \
    rpm -q chromium libavcodec-freeworld ripgrep fzf bat eza fastfetch btop \
           git-core wl-clipboard distrobox >/dev/null; \
    test -s /etc/flatpak/remotes.d/flathub.flatpakrepo || { echo "ERROR: Flathub remote missing" >&2; exit 1; }; \
    flatpak info --system io.github.kolunmi.Bazaar >/dev/null \
      || { echo "ERROR: Bazaar not installed" >&2; exit 1; }; \
    echo "apps OK: chromium $(rpm -q --qf '%{VERSION}' chromium), Bazaar present, CLI tools present"

# --- Update policy: manual only ---
# Two manual streams (bootc + flatpak); nothing updates unattended. Mask both OS auto-update
# timers (mask is stronger than disable — symlinked to /dev/null, can't be started).
RUN systemctl mask bootc-fetch-apply-updates.timer rpm-ostreed-automatic.timer \
 && for t in bootc-fetch-apply-updates.timer rpm-ostreed-automatic.timer; do \
      [ "$(readlink -f "/etc/systemd/system/$t")" = /dev/null ] \
        || { echo "ERROR: $t not masked" >&2; exit 1; }; \
    done \
 && echo "update timers masked: bootc-fetch-apply-updates + rpm-ostreed-automatic"

# --- Image-update trust (backlog/0003) ---
# Roshar boots this image, so it must verify its own update stream (ghcr.io/reinier/roshar).
# Same shared cosign key as Steen/Tashikk/Azir; signedIdentity=matchRepository binds each
# signature to its own repo, so cross-repo authorization is impossible.
# NOTE: requires SIGNING_SECRET (the same key) set on the roshar repo, or the first push is
# UNSIGNED and `bootc upgrade` (once on Roshar) will reject it. First rebase FROM Silverblue
# is still trust-on-first-use regardless.
COPY cosign.pub /usr/share/pki/containers/cosign.pub
COPY patch-policy.py /tmp/patch-policy.py
RUN python3 /tmp/patch-policy.py && rm -f /tmp/patch-policy.py

COPY files/roshar-registries.yaml /usr/share/factory/etc/containers/registries.d/roshar.yaml
RUN mkdir -p /etc/containers/registries.d \
 && cp /usr/share/factory/etc/containers/registries.d/roshar.yaml \
       /etc/containers/registries.d/roshar.yaml

# Fail the build on real bootc issues (warnings are fine).
RUN bootc container lint
