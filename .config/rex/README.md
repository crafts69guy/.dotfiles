# Rex shortcuts

Reload changes with `rex config reload`; validate with `rex config check`.

| Shortcut | Action |
| --- | --- |
| Shift+Cmd+N | Create and display a fresh shell session in `~/Developments` |
| Ctrl+Cmd+G | Open Lazygit in a floating pane at the focused Git checkout |
| Ctrl+Cmd+R | Review local changes with `tuicr -w` in a floating pane |
| Ctrl+Cmd+P | Search GHQ repositories and open a Git checkout in a fresh Rex session |
| Ctrl+Cmd+O | Open Orc Tasks for the focused pane's directory |
| Ctrl+Cmd+A | Open a new tab (like Cmd+T) running the Orc orchestrator (`orc claude`) |
| Ctrl+Cmd+W | Jump to an Orc worker in a small centered picker |
| Ctrl+Cmd+X | Close finished Orc workers for the focused repository |
| Ctrl+Cmd+I | Copy a pane ID from any session on the current Rex server |

## Pane IDs

**Copy Block ID from Picker…** (`copy_pane_id`) opens the native Rex picker with
panes listed by session, including floating panes. Filter by session, tab,
pane label, or block ID. Return copies the full `block:…` ID to the clipboard
on the Rex server's Mac without switching sessions or tabs. The macOS
**Block ID copied** alert closes after two seconds. Esc cancels the picker.
[Rex Custom UI](https://www.superlogical.com/rex/docs/customize/custom-ui)

## GHQ projects and Git worktrees

**Open GHQ Repository in New Session** (`ghq_projects`) uses the Rex native
picker. `init.lua` registers the actions and shortcuts. `ghq-projects.lua` reads
`ghq list --full-path --vcs git` on that Rex server, sorts and deduplicates the
results, and displays each repo's name and full path. Type part of either to
filter. More than 2,000 results trigger a keyword prompt before the list opens.
GHQ emits one path per line, so the picker supports paths without line breaks.
Rex Custom UI requires a server and connected app with prompt support. Prompts
can appear in several connected apps, and the first answer wins. [Rex Custom UI](https://www.superlogical.com/rex/docs/customize/custom-ui)

Git supplies the selected repository's worktree inventory. With one available
checkout, that checkout opens immediately. With several, choose by branch and
path. The list includes detached and locked checkouts that still exist. Bare
entries, stale registrations, and missing directories stay out of the list.
**Open or Create Git Worktree…** (`git_worktrees`) always shows this inventory
for the focused repository, including when it has a single checkout.

**Create or switch to a branch…** accepts a local branch name. A branch already
checked out opens that worktree. An unattached local branch goes straight to
confirmation. For a new branch, choose the Worktrunk default, current checkout
`HEAD`, or a local branch as the base, then confirm. Esc cancels any prompt
before a session is created. Worktrunk runs in the new session's terminal,
applies the configured path template and hooks, and prompts for hook approval
as needed. After switching it starts interactive Fish in the target worktree.
If it fails, the terminal keeps the output. Reopen the worktree inventory
before retrying because the worktree may already be registered. [Worktrunk switch](https://worktrunk.dev/switch/)

Use `wt list` to inspect worktrees and `wt merge` or `wt remove` for their
lifecycle. Use Orc for worktrees owned by active Orc tasks or workers.

Every open creates a new session with a Shell tab. Labels use the repo name
and include the branch or detached HEAD for linked checkouts. A keyboard shortcut
or palette action selects the session in the app that launched it. If focus
fails, find the created session with `rex ls` and select it manually. If Rex
cannot confirm creation, check `rex ls` before invoking the action again.

Pass an exact GHQ-listed path from the CLI to skip the repository prompt.
Without a connected app, the action uses that project's checkout if Git can
resolve it, or the only available worktree. CLI invocations return the created
`session_id` and leave app focus to a separate command. Use `rex client ls` to
find an app, then pass its label or ID and the returned session ID to
`session.select`. [Rex CLI](https://www.superlogical.com/rex/docs/reference/cli#rex-do-action-args)

```fish
rex do ghq_projects 'project=/path/to/ghq/host/owner/repo' --json
rex -C app-label do session.select session_id=session:YOUR_SESSION_ID
```

## Git floating panes

Lazygit and Tuicr start in the focused directory, including subdirectories of
linked worktrees. The actions use the terminal's interactive shell environment
so Lazygit picks up the existing Hue configuration. Local Tuicr review also
works in Jujutsu workspaces. **Review Branch…** (`tuicr_review_branch`) is for
checkouts where Tuicr uses its Git backend. It takes a branch, tag, or commit and shows committed
changes from its merge base with `HEAD`. The CLI accepts the same base as an
argument. For a Jujutsu branch review, use Tuicr's revision selector or a
Jujutsu revset. [Tuicr CLI](https://github.com/agavra/tuicr/blob/main/docs/CLI.md)

```fish
rex do tuicr_review_branch base=origin/production
```

The focused pane must report an existing absolute local directory, normally
through OSC 7. A pane running a program without a shell can report its working
directory through the foreground process instead. Floating actions return the
created layer and block IDs when invoked from the CLI.

## Sessions and Orc

**New Session in Developments** (`new_dev_session`) uses the Rex server's
`HOME .. "/Developments"` as its fixed directory, regardless of the focused pane.
To customize it, change `options.cwd` in that action in `init.lua` to an absolute
server path, then reload the configuration. If the directory is missing, the
terminal falls back to home. The menu's **New Session** action is unchanged.

The Orc tasks and workers popups run `nvim --clean -u orc-popup.lua`,
not the LazyVim configuration. `orc-popup.lua` loads only snacks.nvim (from
Neovim's `stdpath("data")/lazy`), orc.nvim and the Hue theme from their checkouts under
`~/Developments/github.com/crafts69guy`; update it if those move. It requires
`nvim` and `rex` on the terminal's PATH.
If `rex` is absent from PATH, it uses the CLI bundled with `/Applications/Rex Beta.app`.
No native fzf extension is required.

The command palette also offers **Open Orc Tasks** (`orc_tasks`). This opens the
task panel for the focused pane's directory. It does not launch an agent.
The pane must have reported an absolute local directory, normally through OSC 7.
A pane running a program without a shell (such as `orc claude`) never sends OSC 7;
the actions then use the foreground process's working directory.

All four Orc shortcuts require that directory. **Open Orc Orchestrator**
(`orc_orchestrator`) opens a focused new tab named "Orc" in the same session,
like Cmd+T, running `orc claude` in that directory. Orc enables pane
mode automatically inside Rex.

**Jump to Orc Worker** (`orc_workers`) opens the worker picker for that directory;
Enter focuses the selected worker in the originating Rex app. **Close Finished
Orc Workers** (`orc_prune`) runs `orc pane prune --path <directory>` through
`$HOME/.local/bin/orc`, so it does not depend on the server's PATH. It closes
eligible finished workers; failures are reported as action errors.

Automatic switching requires **Settings → Server → Remote Control** enabled in
the Rex app. This allows Rex and other clients to perform actions in that app.

`init.lua` supplies the originating app's client ID to `require("orc").open`
or `require("orc").workers` in a dedicated Neovim process. In an existing
editor use `:Orc projects`, `:Orc`, or `:Orc workers`. Closing those views
keeps the editor running. Closing the worker picker leaves workers running.

Run the isolated regression check from the repository root:

```fish
nvim --headless -u NONE -l .config/rex/integration-test.lua
rex config check .config/rex/init.lua
```
