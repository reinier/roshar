#!/usr/bin/env bash
# Regenerate keymap.svg from keymap.yaml using keymap-drawer.
#
#   pip install keymap-drawer      # one-time
#   ./draw.sh
#
# keymap.yaml is hand-curated (not derived from binds.kdl) — re-derive it by
# hand whenever files/skel-niri/dms/binds.kdl's Mod+<letter> bindings change.
# Same tool/workflow as dotfiles-azir's notes/niri-keymap/.
set -euo pipefail
cd "$(dirname "$0")"
keymap draw keymap.yaml > keymap.svg
echo "wrote keymap.svg"
