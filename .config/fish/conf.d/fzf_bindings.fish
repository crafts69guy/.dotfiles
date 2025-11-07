# FZF Key Bindings with Fn key (mapped to Ctrl+Alt via Karabiner)
#
# Karabiner maps: Fn+key → Ctrl+Alt+key
# Fish binds: Ctrl+Alt+key → fzf functions
# Result: Press Fn+f to trigger fzf_files, etc.
#
# Key mappings:
# - Fn+f (or Ctrl+Alt+f): Fuzzy find files
# - Fn+d (or Ctrl+Alt+d): Fuzzy find directories
# - Fn+g (or Ctrl+Alt+g): Git modified files
# - Fn+b (or Ctrl+Alt+b): Git branches
# - Fn+p (or Ctrl+Alt+p): Projects (ghq)
# - Fn+t (or Ctrl+Alt+t): Tmux sessions
# - Fn+r (or Ctrl+Alt+r): Command history (alt, see Ctrl+r below)
# - Ctrl+r: Command history (standard)

if status is-interactive
    # Fn+f / Ctrl+Alt+f: Fuzzy find files
    bind \e\cf 'fzf_files; commandline -f repaint'

    # Fn+d / Ctrl+Alt+d: Fuzzy find directories
    bind \e\cd 'fzf_directories; commandline -f repaint'

    # Fn+g / Ctrl+Alt+g: Git modified files
    bind \e\cg 'fzf_git_files; commandline -f repaint'

    # Fn+b / Ctrl+Alt+b: Git branches
    bind \e\cb 'fzf_git_branches; commandline -f repaint'

    # Fn+p / Ctrl+Alt+p: Projects
    bind \e\cp 'fzf_projects; commandline -f repaint'

    # Fn+t / Ctrl+Alt+t: Tmux sessions
    # NOTE: Ctrl+Alt+t might conflict with terminal new tab - use Fn+t instead
    bind \e\ct 'fzf_tmux_sessions; commandline -f repaint'

    # Fn+r / Ctrl+Alt+r: Command history (alternative)
    bind \e\cr 'fzf_history; commandline -f repaint'

    # Ctrl+r: Command history (standard, overrides default fish behavior)
    bind \cr 'fzf_history; commandline -f repaint'
end
