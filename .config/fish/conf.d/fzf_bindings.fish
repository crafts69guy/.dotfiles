# FZF Key Bindings with Fn key (mapped to Ctrl+Alt via Karabiner)
# Based on: https://github.com/junegunn/fzf
#
# Karabiner maps: Fn+key → Ctrl+Alt+key
# Fish binds: Ctrl+Alt+key → fzf functions
# Result: Press Fn+f to trigger fzf_files, etc.
#
# ┌─────────────────────────────────────────────────────────────┐
# │ Keybinding          │ Function              │ Description   │
# ├─────────────────────┼───────────────────────┼───────────────┤
# │ Fn+f / Ctrl+Alt+f   │ fzf_files            │ 󰈔 Files        │
# │ Fn+d / Ctrl+Alt+d   │ fzf_directories      │ 󰉋 Directories  │
# │ Fn+g / Ctrl+Alt+g   │ fzf_git_files        │  Git changes  │
# │ Fn+b / Ctrl+Alt+b   │ fzf_git_branches     │  Git branches │
# │ Fn+; / Ctrl+Alt+;   │ fzf_git_log          │ 󰜘 Git log      │
# │ Fn+p / Ctrl+Alt+p   │ fzf_projects         │  Projects     │
# │ Fn+t / Ctrl+Alt+t   │ fzf_tmux_sessions    │  Tmux         │
# │ Fn+w / Ctrl+Alt+w   │ fzf_tmux_windows     │  Tmux windows │
# │ Fn+q / Ctrl+Alt+q   │ fzf_tmux_kill        │ 󰆴 Kill session │
# │ Fn+n / Ctrl+Alt+n   │ fzf_tmux_new_session │  New session  │
# │ Fn+s / Ctrl+Alt+s   │ fzf_ripgrep          │  Ripgrep      │
# │ Fn+x / Ctrl+Alt+x   │ fzf_processes        │ 󰓛 Processes    │
# │ Fn+o / Ctrl+Alt+o   │ fzf_ports            │ 󰒍 Ports        │
# │ Fn+m / Ctrl+Alt+m   │ dev-session          │  Dev session  │
# │ Ctrl+r              │ fzf_history          │ 󰋚 History      │
# └─────────────────────────────────────────────────────────────┘
#
# Not bound (call manually):
#   fzf_kill [-9]  - Quick kill (no confirm)
#   fzf_rg <pat>   - Two-phase ripgrep

if status is-interactive
    # ─── File Navigation ───────────────────────────────────────
    bind \e\cf 'fzf_files; commandline -f repaint'
    bind \e\cd 'fzf_directories; commandline -f repaint'

    # ─── Git ───────────────────────────────────────────────────
    bind \e\cg 'fzf_git_files; commandline -f repaint'
    bind \e\cb 'fzf_git_branches; commandline -f repaint'
    bind \e\; 'fzf_git_log; commandline -f repaint'

    # ─── Projects & Sessions ───────────────────────────────────
    bind \e\cp 'fzf_projects; commandline -f repaint'
    bind \e\ct 'fzf_tmux_sessions; commandline -f repaint'
    bind \e\cw 'fzf_tmux_windows; commandline -f repaint'
    bind \e\cq 'fzf_tmux_kill; commandline -f repaint'
    bind \e\cn 'fzf_tmux_new_session; commandline -f repaint'
    bind \e\cm 'dev-session; commandline -f repaint'

    # ─── Search ────────────────────────────────────────────────
    bind \e\cs 'fzf_ripgrep; commandline -f repaint'

    # ─── Process Management ────────────────────────────────────
    bind \e\cx 'fzf_processes; commandline -f repaint'
    bind \e\co 'fzf_ports; commandline -f repaint'

    # ─── History ───────────────────────────────────────────────
    bind \e\cr 'fzf_history; commandline -f repaint'
    bind \cr 'fzf_history; commandline -f repaint'
end
