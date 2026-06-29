#!/usr/bin/env bash
#
# Sync the Hue Ghostty theme from the hue-theme repo into the Ghostty themes dir.
# Ghostty has no plugin/remote-theme mechanism, so the theme is a local file kept
# in sync with its generated source. Run with --check (e.g. in stow_setup.sh or a
# pre-commit hook) to detect drift without writing.
#
# Usage: sync-hue-ghostty.sh [--ref <git-ref>] [--mood mua|huong|cung] [--check]

set -euo pipefail

REF="main"
MOOD="mua"
CHECK=""
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/themes"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref) REF="$2"; shift 2 ;;
    --mood) MOOD="$2"; shift 2 ;;
    --check) CHECK=1; shift ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

URL="https://raw.githubusercontent.com/crafts69guy/hue-theme/${REF}/packages/terminal-themes/ghostty/hue-${MOOD}"
DEST="${DEST_DIR}/hue-${MOOD}"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
if ! curl -fsSL "$URL" -o "$tmp"; then
  echo "ERROR: failed to fetch $URL" >&2
  exit 1
fi

if [[ -n "$CHECK" ]]; then
  if diff -q "$tmp" "$DEST" >/dev/null 2>&1; then
    echo "hue-ghostty: $DEST is up to date (ref=$REF)"
    exit 0
  fi
  echo "hue-ghostty: $DEST differs from ref=$REF — run without --check to update" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"
cp "$tmp" "$DEST"
echo "hue-ghostty: wrote $DEST (ref=$REF, mood=$MOOD)"
