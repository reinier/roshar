# Local build: build Roshar on the machine itself

- **Status:** open (nothing built or tested yet)
- **Created:** 2026-10-07
- **Related:** `azir` backlog `0007` — the full local-build-and-switch workflow (build as
  root, `bootc switch --transport containers-storage`, updating, switching back, building
  on one machine and running on another). This item only covers what's Roshar-specific.

## Why

Self-build fallback for the whole chain, not just Azir: if GitHub Actions or ghcr.io is
unavailable, Roshar has to be buildable locally too, since Azir is built `FROM` it.
Also useful to test a Roshar change and an Azir build on top of it before pushing either.

## Build

```bash
cd ~/dev/AzirOS/roshar && git pull
sudo podman build -t localhost/roshar:local .
```

- Base is `quay.io/fedora-ostree-desktops/silverblue:44` — Fedora's own image, not
  GitHub-hosted, so this works without GitHub entirely (CI: ~4 min on 4 vCPU).
- Root, not rootless: bootc and the Azir build both read root's container storage.
- Ends with `RUN bootc container lint`.

## Use it

- **As the base for Azir** (the usual case): build Azir with
  `--build-arg ROSHAR_IMAGE=localhost/roshar:local` — needs the `ROSHAR_IMAGE` build
  argument from `azir` `0007` step 1.
- **Boot it directly** (only to test Roshar on its own):
  `sudo bootc switch --transport containers-storage localhost/roshar:local`, then reboot;
  back with `sudo bootc switch ghcr.io/reinier/azir:latest`.

## Note on trust

The image this builds still carries the `ghcr.io/reinier` sigstore trust rule
(`patch-policy.py`) and `registries.d` entry, unchanged — a local build doesn't alter what
the resulting system trusts for its normal (CI) updates.

## Acceptance

1. Local build succeeds; note build time and `/var` usage here.
2. Azir builds on top of it (`azir` `0007` with `ROSHAR_IMAGE=localhost/roshar:local`)
   and that image boots.
