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

## ghq plugin

Project navigation lives in the `ghq` plugin (`crafts69guy/herdr-ghq`, linked
locally from `~/Developments/github.com/crafts69guy/herdr-ghq`): `prefix+space` →
`ghq.menu` opens a themed **unified switcher** — a Rust TUI (`src/`, built on
first run to `target/release/herdr-ghq-switcher` by `bin/picker.sh`) blending
running agents, open workspaces, and `ghq list` repos. Accept is kind-aware: `enter` on an agent = `herdr agent
focus`, on a workspace = `herdr workspace focus`, on a repo = open in the
configurable `default_target` (workspace). `ctrl-w/t/s/o` = workspace/tab/split/
cd-current-pane (repo path, or an agent's cwd), `ctrl-g` opens a tab + hands off
to the git-hub menu, `ctrl-u` `ghq get -u`, `ctrl-x` remove (typed confirm),
`alt-enter` clone. Layout: Search box top, Switcher list + Preview
(`preview_position` right/down/up/left) with a full-width coloured-pill command
bar pinned to the bottom (fzf couldn't do that under a side preview, hence the
Rust rewrite). The TUI reads herdr/ghq JSON with serde, fuzzy-filters with
nucleo, and reuses `bin/preview.sh` for preview content. Needs `cargo` (brew
install rust) to build the binary.

One binary, several modes, each with a thin `bin/` wrapper that execs
`bin/picker.sh <flag>` so the on-demand build is never duplicated: no flag = the
switcher, `--settings` = the settings form, `--changelog` = the changelog viewer,
`--update-check` = a headless fetch. **The plugin needs no fzf** (as of v0.6.0);
only `bin/get.sh` (clone) is still bash, and it prompts with `read`.

Actions: `ghq.menu`, `ghq.get`, `ghq.settings` (popup), `ghq.changelog` (popup),
`ghq.update-plugin`, and `open-workspace/tab/split` which force Enter's target
(repo-only). Flat `config.toml` in the plugin config dir (`default_target`,
`include_agents`, `include_workspaces`, `title_color`, `preview_position`,
`preview_size`, `split_*`, `update_check`, …), edited via the settings action.

`update_check` (default true) spawns a **detached** `--update-check` child once a
day that runs `git ls-remote` and caches the newest tag in
`$XDG_STATE_HOME/herdr-ghq/update.tsv`; the picker only reads that file and shows
`↑ vX.Y.Z` in the command bar. The TUI itself never makes a network request — the
fetch takes seconds and the picker usually exits in under one, so a thread inside
it would be killed before writing. `ghq.update-plugin` installs a newer version but
**refuses when `source.kind` is not `github`**, which is the case for this linked
checkout: pull it by hand, rebuild, and relink.

Supersedes `fzf_projects.fish` inside herdr (the fish function stays as a
non-herdr fallback). Extend the plugin rather than adding standalone ghq scripts.

## Verifying integration health

- `herdr integration status` shows which agents have hooks installed and
  whether they're current.
- `herdr status` shows local client/server state.
- Prefer `herdr <subcommand> --help` for exact current CLI flags over
  assuming syntax from the public docs at herdr.dev/docs — the CLI has moved
  ahead of the docs before (e.g. `pane split`'s `--ratio`/`--no-focus` flags).
