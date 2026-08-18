#!/usr/bin/env bash
#
# Sync the Hue delta themes from the hue-theme repo into ~/.config/git. delta
# reads its options from git config, so these are *included* by .gitconfig
# rather than copied over anything: the include points at the
# hue-current.gitconfig symlink (switched by hue-theme.fish), and .gitconfig's
# `[delta] features = hue` is written once. Run with --check (e.g. in
# stow_setup.sh) to detect drift without writing.
#
# Usage: sync-hue-delta.sh [--ref <git-ref>] [--check]

set -euo pipefail

REF="main"
CHECK=""
MOODS=(mua huong cung)
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/git/hue-themes"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref) REF="$2"; shift 2 ;;
    --check) CHECK=1; shift ;;
    -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

status=0
for mood in "${MOODS[@]}"; do
  URL="https://raw.githubusercontent.com/crafts69guy/hue-theme/${REF}/packages/terminal-themes/delta/hue-${mood}.gitconfig"
  DEST="${DEST_DIR}/hue-${mood}.gitconfig"

  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT
  if ! curl -fsSL "$URL" -o "$tmp"; then
    echo "ERROR: failed to fetch $URL" >&2
    exit 1
  fi

  if [[ -n "$CHECK" ]]; then
    if diff -q "$tmp" "$DEST" >/dev/null 2>&1; then
      echo "hue-delta: $DEST is up to date (ref=$REF)"
    else
      echo "hue-delta: $DEST differs from ref=$REF — run without --check to update" >&2
      status=1
    fi
  else
    mkdir -p "$DEST_DIR"
    cp "$tmp" "$DEST"
    echo "hue-delta: wrote $DEST (ref=$REF)"
  fi
  rm -f "$tmp"
done

# Keep the mood symlink present so the .gitconfig include always resolves — a
# dangling include is silently ignored by git, which looks exactly like a theme
# that did not land.
if [[ -z "$CHECK" && ! -e "${DEST_DIR}/hue-current.gitconfig" ]]; then
  ln -sf "hue-mua.gitconfig" "${DEST_DIR}/hue-current.gitconfig"
  echo "hue-delta: created hue-current.gitconfig -> hue-mua.gitconfig"
fi
exit $status
