#!/usr/bin/env bash
#
# Install a launchd agent that keeps the Hue Rex watcher running, so terminals
# opened after login (or after a Rex server restart) get the last applied mood.
# init.lua can't do this itself: Rex API calls don't work at config load time,
# and rex.on only works in `rex do` scripts. The plist is written per machine
# (absolute paths to the rex CLI and $HOME) and is not tracked in dotfiles.
#
# Usage: hue-rex-agent.sh install [--mood mua|huong|cung] | uninstall | status

set -euo pipefail

LABEL="com.crafts69guy.hue-rex-watch"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
WATCHER="${XDG_CONFIG_HOME:-$HOME/.config}/rex/hue-watch.lua"
LOG="$HOME/Library/Logs/hue-rex-watch.log"
DOMAIN="gui/$(id -u)"

# The CLI that matches the running server: Rex puts it on PATH only inside its
# own terminals, so fall back to the copy inside the app bundle.
rex_bin() {
  local app="/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex"
  if [[ -n "${REX_BIN_DIR:-}" && -x "$REX_BIN_DIR/rex" ]]; then echo "$REX_BIN_DIR/rex"
  elif command -v rex >/dev/null 2>&1; then command -v rex
  elif [[ -x "$app" ]]; then echo "$app"
  else echo "ERROR: rex CLI not found" >&2; return 1
  fi
}

install() {
  local mood="mua"
  [[ "${1:-}" == "--mood" ]] && mood="$2"
  [[ -f "$WATCHER" ]] || { echo "ERROR: $WATCHER missing — run sync-hue-rex.sh first" >&2; exit 1; }
  local rex; rex="$(rex_bin)"

  mkdir -p "$(dirname "$PLIST")" "$(dirname "$LOG")"
  cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>${LABEL}</string>
  <key>ProgramArguments</key>
  <array>
    <string>${rex}</string>
    <string>do</string>
    <string>--all</string>
    <string>${WATCHER}</string>
    <string>mood=${mood}</string>
  </array>
  <key>RunAtLoad</key><true/>
  <!-- rex do exits when the server goes away; launchd restarts it, at most every 30s. -->
  <key>KeepAlive</key><true/>
  <key>ThrottleInterval</key><integer>30</integer>
  <key>StandardOutPath</key><string>${LOG}</string>
  <key>StandardErrorPath</key><string>${LOG}</string>
</dict>
</plist>
PLIST
  plutil -lint "$PLIST" >/dev/null

  launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
  launchctl bootstrap "$DOMAIN" "$PLIST"
  echo "hue-rex-agent: loaded $LABEL (mood fallback=$mood, log=$LOG)"
}

uninstall() {
  launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
  rm -f "$PLIST"
  echo "hue-rex-agent: removed $LABEL"
}

case "${1:-}" in
  install) shift; install "$@" ;;
  uninstall) uninstall ;;
  status) launchctl print "$DOMAIN/$LABEL" | grep -E '^\s*(state|pid|last exit code) =' ;;
  *) sed -n '2,9p' "$0"; exit 2 ;;
esac
