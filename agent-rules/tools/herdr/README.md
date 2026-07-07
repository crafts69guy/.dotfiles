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
- Plugins in general cannot edit `config.toml`, register keybindings, or call
  a "set theme" API themselves — they can only run argv commands
  (bash/JS/Lua/etc.) via `[[keys.command]] type = "plugin_action"`, an event
  hook, or `herdr plugin action invoke`.

## Verifying integration health

- `herdr integration status` shows which agents have hooks installed and
  whether they're current.
- `herdr status` shows local client/server state.
- Prefer `herdr <subcommand> --help` for exact current CLI flags over
  assuming syntax from the public docs at herdr.dev/docs — the CLI has moved
  ahead of the docs before (e.g. `pane split`'s `--ratio`/`--no-focus` flags).
