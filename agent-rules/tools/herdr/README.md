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
  (`~/.config/herdr/config.toml`, override via `HERDR_CONFIG_PATH`). Any
  generated/templated content (e.g. the Hue Tide theme sync) must patch that
  file's marked blocks directly, then call `herdr server reload-config` — it
  cannot be split into a separately-sourced file the way fish/tmux configs are.

## Verifying integration health

- `herdr integration status` shows which agents have hooks installed and
  whether they're current.
- `herdr status` shows local client/server state.
- Prefer `herdr <subcommand> --help` for exact current CLI flags over
  assuming syntax from the public docs at herdr.dev/docs — the CLI has moved
  ahead of the docs before (e.g. `pane split`'s `--ratio`/`--no-focus` flags).
