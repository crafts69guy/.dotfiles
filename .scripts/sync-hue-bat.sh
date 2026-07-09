#!/usr/bin/env bash
#
# Sync the Hue bat themes from the hue-theme repo into bat's themes dir and
# rebuild bat's theme cache. bat has no plugin/remote-theme mechanism, so the
# .tmTheme files are local copies kept in sync with their generated source.
# Run with --check (e.g. in stow_setup.sh or a pre-commit hook) to detect
# drift without writing.
#
# Usage: sync-hue-bat.sh [--ref <git-ref>] [--check]

set -euo pipefail

REF="main"
CHECK=""
MOODS=(mua huong cung)
DEST_DIR="$(bat --config-dir)/themes"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref) REF="$2"; shift 2 ;;
    --check) CHECK=1; shift ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

status=0
changed=""
for mood in "${MOODS[@]}"; do
  URL="https://raw.githubusercontent.com/crafts69guy/hue-theme/${REF}/packages/terminal-themes/bat/hue-${mood}.tmTheme"
  DEST="${DEST_DIR}/hue-${mood}.tmTheme"

  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT
  if ! curl -fsSL "$URL" -o "$tmp"; then
    echo "ERROR: failed to fetch $URL" >&2
    exit 1
  fi

  if [[ -n "$CHECK" ]]; then
    if diff -q "$tmp" "$DEST" >/dev/null 2>&1; then
      echo "hue-bat: $DEST is up to date (ref=$REF)"
    else
      echo "hue-bat: $DEST differs from ref=$REF — run without --check to update" >&2
      status=1
    fi
  else
    mkdir -p "$DEST_DIR"
    cp "$tmp" "$DEST"
    changed=1
    echo "hue-bat: wrote $DEST (ref=$REF)"
  fi
  rm -f "$tmp"
done

if [[ -n "$changed" ]]; then
  bat cache --build >/dev/null
  echo "hue-bat: rebuilt bat theme cache"
fi
exit $status
