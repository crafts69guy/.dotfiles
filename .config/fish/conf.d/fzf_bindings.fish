# FZF Key Bindings with Fn key (mapped to Ctrl+Alt via Karabiner)
# Based on: https://github.com/junegunn/fzf
#
# Karabiner maps: Fn+key → Ctrl+Alt+key
# Fish binds: Ctrl+Alt+key → fzf functions
# Result: Press Fn+f to trigger fzf_files, etc.
#
# Key mappings:
# - Fn+f (or Ctrl+Alt+f): Fuzzy find files (fd + bat)
# - Fn+d (or Ctrl+Alt+d): Fuzzy find directories (fd + eza)
# - Fn+g (or Ctrl+Alt+g): Git modified files
# - Fn+b (or Ctrl+Alt+b): Git branches
# - Fn+p (or Ctrl+Alt+p): Projects (ghq)
# - Fn+t (or Ctrl+Alt+t): Tmux sessions
# - Fn+s (or Ctrl+Alt+s): Interactive ripgrep search
# - Fn+x (or Ctrl+Alt+x): Kill processes (x=terminate)
# - Fn+o (or Ctrl+Alt+o): Kill processes by port
# - Fn+r (or Ctrl+Alt+r): Command history (alt, see Ctrl+r below)
# - Ctrl+r: Command history (standard)

if status is-interactive
    # Fn+f / Ctrl+Alt+f: Fuzzy find files (fd + bat)
    bind \e\cf 'fzf_files; commandline -f repaint'

    # Fn+d / Ctrl+Alt+d: Fuzzy find directories (fd + eza)
    bind \e\cd 'fzf_directories; commandline -f repaint'

    # Fn+g / Ctrl+Alt+g: Git modified files
    bind \e\cg 'fzf_git_files; commandline -f repaint'

    # Fn+b / Ctrl+Alt+b: Git branches
    bind \e\cb 'fzf_git_branches; commandline -f repaint'

    # Fn+p / Ctrl+Alt+p: Projects (ghq)
    bind \e\cp 'fzf_projects; commandline -f repaint'

    # Fn+t / Ctrl+Alt+t: Tmux sessions
    # NOTE: Ctrl+Alt+t might conflict with terminal new tab - use Fn+t instead
    bind \e\ct 'fzf_tmux_sessions; commandline -f repaint'

    # Fn+s / Ctrl+Alt+s: Interactive ripgrep search
    bind \e\cs 'fzf_ripgrep; commandline -f repaint'

    # Fn+x / Ctrl+Alt+x: Kill processes (x = terminate)
    bind \e\cx 'fzf_processes; commandline -f repaint'

    # Fn+o / Ctrl+Alt+o: Kill processes by port
    bind \e\co 'fzf_ports; commandline -f repaint'

    # Fn+r / Ctrl+Alt+r: Command history (alternative)
    bind \e\cr 'fzf_history; commandline -f repaint'

    # Ctrl+r: Command history (standard, overrides default fish behavior)
    bind \cr 'fzf_history; commandline -f repaint'
end
