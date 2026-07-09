#!/usr/bin/env bash
#
# Sync the Hue lazygit themes from the hue-theme repo into lazygit's themes
# dir. lazygit has no plugin/remote-theme mechanism; the fragments are local
# copies merged in via LG_CONFIG_FILE (see conf.d/00-hue-tide.fish). Run with
# --check (e.g. in stow_setup.sh or a pre-commit hook) to detect drift
# without writing.
#
# Usage: sync-hue-lazygit.sh [--ref <git-ref>] [--check]

set -euo pipefail

REF="main"
CHECK=""
MOODS=(mua huong cung)
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/lazygit/themes"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref) REF="$2"; shift 2 ;;
    --check) CHECK=1; shift ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

status=0
for mood in "${MOODS[@]}"; do
  URL="https://raw.githubusercontent.com/crafts69guy/hue-theme/${REF}/packages/terminal-themes/lazygit/hue-${mood}.yml"
  DEST="${DEST_DIR}/hue-${mood}.yml"

  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT
  if ! curl -fsSL "$URL" -o "$tmp"; then
    echo "ERROR: failed to fetch $URL" >&2
    exit 1
  fi

  if [[ -n "$CHECK" ]]; then
    if diff -q "$tmp" "$DEST" >/dev/null 2>&1; then
      echo "hue-lazygit: $DEST is up to date (ref=$REF)"
    else
      echo "hue-lazygit: $DEST differs from ref=$REF — run without --check to update" >&2
      status=1
    fi
  else
    mkdir -p "$DEST_DIR"
    cp "$tmp" "$DEST"
    echo "hue-lazygit: wrote $DEST (ref=$REF)"
  fi
  rm -f "$tmp"
done

# Keep the mood symlink present so LG_CONFIG_FILE always resolves.
if [[ -z "$CHECK" && ! -e "${DEST_DIR}/hue-current.yml" ]]; then
  ln -sf "hue-mua.yml" "${DEST_DIR}/hue-current.yml"
  echo "hue-lazygit: created hue-current.yml -> hue-mua.yml"
fi
exit $status
