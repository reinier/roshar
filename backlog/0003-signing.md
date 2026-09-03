# Signed update stream

- **Status:** done — `SIGNING_SECRET` confirmed set on `reinier/roshar` (2026-09-03); a
  manually-triggered build's push log showed `Creating signature: Signing image using a
  sigstore signature` + `Storing signatures`, not the unsigned fallback.
- **Created:** 2026-09-02
- **Related:** Steen/Tashikk/Azir's own `0001`/signing items (same machinery).

## What's baked

Roshar verifies its own update stream (`ghcr.io/reinier/roshar`): a baked `cosign.pub` + a
`sigstoreSigned` `policy.json` entry (`patch-policy.py`, keyed on the `ghcr.io/reinier`
namespace, `signedIdentity: matchRepository`) + `files/roshar-registries.yaml` for sigstore
attachment reads. CI signs the `:latest` push when `SIGNING_SECRET` is present.

## Shared key — one action needed

The cosign key is **shared** with Steen, Tashikk, and Azir (same `SIGNING_SECRET`).
`matchRepository` binds each signature to its own repo, so none of those three's signatures
can authorize a Roshar pull. **You must set `SIGNING_SECRET` on the `reinier/roshar` repo**
(same private key value) — until then CI pushes UNSIGNED (with a warning).

Because the policy is baked, an unsigned `:latest` will be **rejected by `bootc upgrade`**
once you're on Roshar. The first `bootc switch` *from Silverblue* is still trust-on-first-use
(the source system's policy doesn't require the key), so a first boot-test works either way —
but set the secret before relying on updates.

## Verify

- CI push log shows `--sign-by-sigstore-private-key` + `Storing signatures`.
- `bootc switch` verifies against the baked policy; subsequent `bootc upgrade` is enforced.
