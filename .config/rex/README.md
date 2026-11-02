# Rex shortcuts

Reload changes with `rex config reload`; validate with `rex config check`.

| Shortcut | Action |
| --- | --- |
| Ctrl+Cmd+G | Lazygit in a floating pane |
| Ctrl+Cmd+R | Tuicr in a floating pane |
| Ctrl+Cmd+P | Search ghq repositories and open a new Rex session |

The repository picker uses the existing Neovim configuration and Snacks Picker's
`telescope` layout. It requires `nvim`, `ghq`, and `rex` on the terminal's PATH.
If `rex` is absent from PATH, it uses the CLI bundled with `/Applications/Rex Beta.app`.
No Telescope plugin or fzf dependency is needed.

Automatic switching requires **Settings → Server → Remote Control** enabled in
the Rex app. This allows Rex and other clients to perform actions in that app.

Type to filter, use Ctrl+J / Ctrl+K to move, and press Enter to create a fresh
session with a shell in the selected repository. The session uses the repository's
basename as its label and opens in the Rex app that launched the picker.
Labels longer than 128 characters are truncated.
Esc cancels and closes the floating Neovim without creating a session.
Opening a repository again creates another session, even if its label already exists.

Errors leave the picker open. If creating the session succeeds but switching to
it fails, Enter retries switching to that same session without creating another.
If creation fails or returns an invalid response, further creation is blocked in
that popup because the server may already have created the session. Check `rex ls`
before closing and reopening the picker.
Startup errors appear in a buffer; press Esc or q to close it.

`ghq-picker.lua` returns a function accepting the originating Rex app's client ID;
`init.lua` supplies it when launching the floating Neovim.
The floating actions (`lazygit`, `tuicr`, and `ghq_projects`) return the created
layer and block IDs when invoked from the CLI.

Run the isolated regression check from the repository root:

```fish
nvim --headless -u NONE -l .config/rex/ghq-picker-test.lua
```
