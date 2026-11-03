# Rex shortcuts

Reload changes with `rex config reload`; validate with `rex config check`.

| Shortcut | Action |
| --- | --- |
| Ctrl+Cmd+G | Lazygit in a floating pane |
| Ctrl+Cmd+R | Tuicr in a floating pane |
| Ctrl+Cmd+P | Search ghq repositories and open a new Rex session |

The repository picker uses orc.nvim and the **Snacks** picker that LazyVim
already loads with the existing Neovim configuration. It requires `nvim`, `ghq`, and `rex` on the terminal's PATH.
If `rex` is absent from PATH, it uses the CLI bundled with `/Applications/Rex Beta.app`.
No native fzf extension is required.

The command palette also offers **Open Orc Tasks** (`orc_tasks`). This opens the
task panel for the focused pane's directory. It does not launch an agent.
The pane must have reported an absolute local directory, normally through OSC 7.

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
before trying again. Closing either popup does not close existing workers.

`init.lua` supplies the originating app's client ID to `require("orc").projects`
or `require("orc").open` in a dedicated Neovim process. Orc owns picker/session
logic and the shared Rex adapter; dotfiles owns keybindings and popup layout.
In an existing editor use `:Orc projects` or `:Orc`; closing those views keeps
the editor running. Focus selects the worker's session in the originating app
when the popup supplied a client ID.
Floating actions return the created layer and block IDs when invoked from the CLI.

Run the isolated regression check from the repository root:

```fish
nvim --headless -u NONE -l .config/rex/integration-test.lua
```
