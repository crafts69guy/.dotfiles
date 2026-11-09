# Rex shortcuts

Reload changes with `rex config reload`; validate with `rex config check`.

| Shortcut | Action |
| --- | --- |
| Ctrl+Cmd+G | Lazygit in a floating pane |
| Ctrl+Cmd+R | Tuicr in a floating pane |
| Ctrl+Cmd+P | Search ghq repositories (small centered popup) and open a new Rex session |
| Ctrl+Cmd+O | Open Orc Tasks for the focused pane's directory |
| Ctrl+Cmd+A | Open a new tab (like Cmd+T) running the Orc orchestrator (`orc claude`) |
| Ctrl+Cmd+W | Jump to an Orc worker in a small centered picker |
| Ctrl+Cmd+X | Close finished Orc workers for the focused repository |

The Orc popups (repositories, tasks, workers) run `nvim --clean -u orc-popup.lua`,
not the LazyVim configuration. `orc-popup.lua` loads only snacks.nvim (from
`~/.local/share/nvim/lazy`), orc.nvim and the Hue theme from their checkouts under
`~/Developments/github.com/crafts69guy`; update it if those move. It requires
`nvim`, `ghq`, and `rex` on the terminal's PATH.
If `rex` is absent from PATH, it uses the CLI bundled with `/Applications/Rex Beta.app`.
No native fzf extension is required.

The command palette also offers **Open Orc Tasks** (`orc_tasks`). This opens the
task panel for the focused pane's directory. It does not launch an agent.
The pane must have reported an absolute local directory, normally through OSC 7.

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

Type to filter, use Ctrl+J / Ctrl+K to move, and press Enter to create a fresh
session with a shell in the selected repository. The session uses the repository's
basename as its label and opens in the Rex app that launched the picker.
Labels longer than 128 characters are truncated.
Esc cancels and closes the floating Neovim. Before confirmation it creates no session.
Opening a repository again creates another session, even if its label already exists.

Errors leave the picker open. If creating the session succeeds but switching to
it fails, Enter retries switching to that same session without creating another.
If creation fails or returns an invalid response, further creation is blocked in
that popup because the server may already have created the session. Check `rex ls`
before closing and reopening the picker.
Startup errors appear in a buffer; press Esc or q to close it.
Cancelling while creation is in flight can leave a session; inspect `rex ls`
before trying again. Closing a popup does not close existing workers.

`init.lua` supplies the originating app's client ID to `require("orc").projects`,
`require("orc").open`, or `require("orc").workers` in a dedicated Neovim process.
Orc owns picker/session logic and the shared Rex adapter; dotfiles owns
keybindings and popup layout. In an existing editor use `:Orc projects`, `:Orc`,
or `:Orc workers`; closing those views keeps the editor running.
Focus selects the worker's session in the originating app
when the popup supplied a client ID.
Floating actions return the created layer and block IDs when invoked from the CLI.

Run the isolated regression check from the repository root:

```fish
nvim --headless -u NONE -l .config/rex/integration-test.lua
```
