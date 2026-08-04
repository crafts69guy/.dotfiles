# Herdr Agent Rules

Use this rule pack when configuring herdr (the terminal multiplexer at
https://herdr.dev), scripting its CLI/socket API, or working on panes it
manages that run coding agents.

## What herdr is

herdr is the daily-driver terminal multiplexer in this dotfiles setup
(replacing tmux — see `.config/herdr/config.toml`). It has native lifecycle-hook
integration for several AI coding agents, including Claude Code, and reports
`idle`/`working`/`blocked` pane state without polling.

## Socket API / CLI caution

- `herdr pane`, `herdr workspace`, `herdr tab`, and `herdr agent` subcommands
  control live terminal panes over a socket API — treat scripted use of these
  the same as tmux automation: verify the target pane/workspace ID before
  `close`, `send-text`, or `send-keys`, since a wrong ID acts on whatever pane
  currently holds that ID.
- `herdr integration install <agent>` writes hook files/config for that agent
  directly (e.g. it added a `SessionStart` hook to the live
  `~/.claude/settings.json` for Claude Code). Diff the target config after
  running an install/uninstall rather than assuming it merged cleanly.
- Config is a single TOML file with no include/import system
  (`~/.config/herdr/config.toml`, override via `HERDR_CONFIG_PATH`), and herdr
  has no scriptable theme API (no `herdr theme` subcommand, no socket method).
  The Hue Tide theme is applied by a herdr plugin
  (`crafts69guy/hue-theme` repo, `packages/herdr-plugin`) whose `apply-mood`
  action splices a `[theme.custom]` fragment between `# BEGIN hue-theme` /
  `# END hue-theme` markers in `config.toml` and calls
  `herdr server reload-config`. `hue-theme.fish` triggers it via
  `herdr plugin action invoke apply-mood --plugin hue-theme`; a
  `workspace.created` event hook re-applies it on herdr startup. Don't
  reintroduce a hand-rolled splice script in this repo — extend the plugin
  instead.
- `[theme.custom]` accepts only herdr's catppuccin-shaped `CustomThemeColors`
  slots — `accent`, `panel_bg`, `surface0/1`, `surface_dim`, `overlay0/1`,
  `text`, `subtext0`, `mauve`, `green`, `yellow`, `red`, `blue`, `teal`,
  `peach` — and silently ignores unknown keys (no reload diagnostics).
  Terminal-style keys (`background`, `foreground`, `cursor`, `selection_*`,
  ANSI names) are no-ops despite appearing in older configs; per-slot UI roles
  are documented in hue-theme's `packages/tokens/src/adapters/herdr.ts`. A
  `theme.custom.accent` value overrides `[ui].accent`. Verified against herdr
  0.7.3 (2026-07).
- Never start a second "isolated" herdr server to test config: even with
  `HERDR_CONFIG_PATH`/`HERDR_SOCKET_PATH` overridden it still shares
  `~/.config/herdr/session.json` and will restore AND re-save the live
  session. Probe the live server with a temporary config edit +
  `herdr server reload-config`, then restore.
- Plugins in general cannot edit `config.toml`, register keybindings, or call
  a "set theme" API themselves — they can only run argv commands
  (bash/JS/Lua/etc.) via `[[keys.command]] type = "plugin_action"`, an event
  hook, or `herdr plugin action invoke`.
- Keybindings accept only the prefix plus ONE (optionally modified) key:
  chord forms like `prefix+g+d` and `"prefix+g d"` are both rejected as
  `invalid keybinding` on reload. Grouping many commands behind one key needs
  a picker pane instead — that is what the git-hub plugin's `menu` action is
  for (see below).
- `herdr plugin pane open --target-pane` is only valid with
  `--placement split`; overlay/tab/zoomed placements reject it with
  `invalid_params` ("overlay plugin panes target the active pane").
- **`herdr server reload-config` does NOT re-read plugin manifests.** It reloads
  `~/.config/herdr/config.toml` only. A manifest (`herdr-plugin.toml`) is read at
  `plugin link` / `plugin install` time and cached in `~/.config/herdr/plugins.json`;
  nothing re-reads it afterwards. A linked checkout whose manifest changed kept
  reporting a version three releases stale in `herdr plugin list` until it was
  relinked. After editing a manifest: `herdr plugin unlink <id> && herdr plugin link
  <path>`. Corollary for plugin code: never read your own version from `herdr plugin
  list` — bake it in at build time. Verified against herdr 0.7.4 (2026-07).
- **Popup plugin panes** (herdr 0.7.4+): `herdr plugin pane open ... --placement popup
  [--width SIZE] [--height SIZE]`, or `placement`/`width`/`height` in the manifest's
  `[[panes]]`. SIZE is cells (a bare integer) or a percentage. herdr draws the popup's
  frame and title, and that frame costs the pane **2 columns and 2 rows**: a
  `--width 88 --height 20` popup hands its command an 86x18 PTY. A TUI in a popup
  should therefore not draw its own bordered box — it doubles the title and overflows
  a window sized to fit. (An overlay pane is framed too; herdr requires a non-empty
  pane title, so the usual dodge is to set the title to a single icon.)
- Plugin panes do not appear in `herdr pane list` or `herdr api snapshot`, so a
  plugin pane cannot be found or closed by scanning those. `herdr plugin pane close`
  takes a pane id.
- **There is no `herdr plugin update`.** Updating a GitHub-installed plugin means
  re-running `herdr plugin install <owner>/<repo>` (it re-fetches the ref shallowly).
  `herdr plugin list --plugin <id> --json` reports `source.kind` (`local` for `link`,
  `github` for `install`) plus `plugin_root`, `requested_ref`, `resolved_commit`, and
  `managed_path`. Any script that re-installs must check `source.kind` first and fail
  closed: running `plugin install` against a `link`ed plugin would overwrite the
  development checkout it points at.
- `herdr notification show <title> [--body TEXT] [--position top-left|top-right|
  bottom-left|bottom-right] [--sound none|done|request]` pushes a toast from a plugin
  to the user outside its own pane (what `notify()` in the ghq/git-hub `lib.sh` wraps).
- Plugin pane commands inherit the herdr server's environment, so user shell
  defaults leak in: `FZF_DEFAULT_OPTS` (e.g. `--height=40%`) shrank a plugin's
  fzf popup and hid entries behind a scrollbar. TUI scripts in plugin panes
  should reset such env vars and use `stty size` (not `tput lines`, which is
  unreliable in the popup PTY).

## git-hub plugin

The git workflow lives in the `git-hub` plugin (`crafts69guy/herdr-git-hub`,
linked locally from `~/Developments/github.com/crafts69guy/herdr-git-hub`):
`prefix+g` → `git-hub.menu` opens an fzf picker (lazygit auto-detected, five
codediff.nvim review actions, extras from
`~/.config/herdr/plugins/config/git-hub/menu.conf`, format
`key|icon|label|shell command`). Review actions open codediff.nvim in an
isolated `NVIM_APPNAME=herdr-git-hub` runtime themed from `[theme.custom]`
with a hue-nvim layer when a Hue mood is active. Extend the plugin (menu.conf
for personal tools, the repo for behavior) rather than adding standalone git
menu scripts to the dotfiles. herdr's default `goto` binding was moved to
`prefix+alt+g` to free `prefix+g`.

## Switchboard plugin

Terminal navigation and operations live in the `switchboard` plugin
(`crafts69guy/herdr-switchboard`, linked locally from
`~/Developments/github.com/crafts69guy/herdr-switchboard`). `prefix+space` invokes
`switchboard.projects`; `prefix+g` invokes `switchboard.git`. The central
`switchboard.menu` popup routes to every picker and utility, while direct actions
`switchboard.projects`, `switchboard.commands`, and `switchboard.ports` can each
be bound independently.

The Rust TUI builds to `target/release/herdr-switchboard` through `bin/picker.sh`.
Projects blends running agents, open workspaces, `ghq list` repositories, and
linked worktrees. Commands searches exact shell history and presets. Ports
inspects live TCP listeners and performs identity-checked process actions. The
package uses namespaced configuration tables under the `switchboard` plugin
config directory and stores runtime state under
`$XDG_STATE_HOME/herdr-switchboard`.

Actions also include `switchboard.settings`, `switchboard.git`,
`switchboard.clone`, `switchboard.changelog`, `switchboard.update`, and the
repo-targeted `switchboard.open-workspace/tab/split`. The update action refuses
to reinstall a locally linked checkout. After changing the plugin manifest,
unlink and relink the checkout because `herdr server reload-config` only reloads
Herdr's main config.

Switchboard supersedes `fzf_projects.fish` inside Herdr; keep `ghq` references
that describe the repository manager itself, but use the `switchboard` namespace
for every Herdr plugin action.

## Verifying integration health

- `herdr integration status` shows which agents have hooks installed and
  whether they're current.
- `herdr status` shows local client/server state.
- Prefer `herdr <subcommand> --help` for exact current CLI flags over
  assuming syntax from the public docs at herdr.dev/docs — the CLI has moved
  ahead of the docs before (e.g. `pane split`'s `--ratio`/`--no-focus` flags).
