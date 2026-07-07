#!/usr/bin/env bash
#
# Sync the Hue herdr theme fragment from the hue-theme repo into a local cache.
# herdr's config.toml has no include/import system, so the fragment is cached
# here and then spliced into ~/.config/herdr/config.toml's [theme.custom] block
# by hue-theme.fish's __hue_theme_apply_herdr, rather than sourced directly.
# Run with --check (e.g. in stow_setup.sh) to detect drift without writing.
#
# Usage: sync-hue-herdr.sh [--ref <git-ref>] [--mood mua|huong|cung] [--check]

set -euo pipefail

REF="main"
MOOD="mua"
CHECK=""
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/herdr/generated"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref) REF="$2"; shift 2 ;;
    --mood) MOOD="$2"; shift 2 ;;
    --check) CHECK=1; shift ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

URL="https://raw.githubusercontent.com/crafts69guy/hue-theme/${REF}/packages/terminal-themes/herdr/hue-${MOOD}.toml"
DEST="${DEST_DIR}/hue-${MOOD}.toml"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
if ! curl -fsSL "$URL" -o "$tmp"; then
  echo "ERROR: failed to fetch $URL (has packages/terminal-themes/herdr/ been added to hue-theme yet?)" >&2
  exit 1
fi

if [[ -n "$CHECK" ]]; then
  if diff -q "$tmp" "$DEST" >/dev/null 2>&1; then
    echo "hue-herdr: $DEST is up to date (ref=$REF)"
    exit 0
  fi
  echo "hue-herdr: $DEST differs from ref=$REF — run without --check to update" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"
cp "$tmp" "$DEST"
echo "hue-herdr: wrote $DEST (ref=$REF, mood=$MOOD)"
