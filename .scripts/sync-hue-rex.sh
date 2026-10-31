#!/usr/bin/env bash
#
# Sync the Hue Rex module and watcher from the hue-theme repo into Rex's config
# dir. Rex has no theme file format, so the theme is a generated Lua module
# (required from init.lua) plus a `rex do` watcher run by hue-rex-agent.sh. Run
# with --check (e.g. in stow_setup.sh) to detect drift without writing.
#
# Usage: sync-hue-rex.sh [--ref <git-ref>] [--check]

set -euo pipefail

REF="main"
CHECK=""
FILES=(hue.lua hue-watch.lua)
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/rex"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref) REF="$2"; shift 2 ;;
    --check) CHECK=1; shift ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

status=0
for file in "${FILES[@]}"; do
  URL="https://raw.githubusercontent.com/crafts69guy/hue-theme/${REF}/packages/terminal-themes/rex/${file}"
  DEST="${DEST_DIR}/${file}"

  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT
  if ! curl -fsSL "$URL" -o "$tmp"; then
    echo "ERROR: failed to fetch $URL" >&2
    exit 1
  fi

  if [[ -n "$CHECK" ]]; then
    if diff -q "$tmp" "$DEST" >/dev/null 2>&1; then
      echo "hue-rex: $DEST is up to date (ref=$REF)"
    else
      echo "hue-rex: $DEST differs from ref=$REF — run without --check to update" >&2
      status=1
    fi
  else
    mkdir -p "$DEST_DIR"
    cp "$tmp" "$DEST"
    echo "hue-rex: wrote $DEST (ref=$REF)"
  fi
  rm -f "$tmp"
done
exit $status
