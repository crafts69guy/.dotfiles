# React Native: force New Architecture for CocoaPods and Xcode builds
set -gx RCT_NEW_ARCH_ENABLED 1
set -gx REACT_TERMINAL Ghostty

# Android development
if /usr/libexec/java_home &>/dev/null
    set -gx JAVA_HOME (/usr/libexec/java_home)
end
if test -d $HOME/Library/Android/sdk
    set -gx ANDROID_HOME $HOME/Library/Android/sdk
    fish_add_path $ANDROID_HOME/emulator $ANDROID_HOME/platform-tools
end

# Local secrets (not tracked by git)
test -f (dirname (status --current-filename))/config-local.fish
and source (dirname (status --current-filename))/config-local.fish

# fnm - Fast Node Manager (must init first)
fnm env | source

# pnpm
set -gx PNPM_HOME /Users/caongoccuong/Library/pnpm

if status is-interactive
    set -gx TERM tmux-256color

    # aliases
    alias ls "ls -p -G"
    alias la "ls -A"
    alias ll "ls -l"
    alias lla "ll -A"
    alias g git
    alias c claude
    alias claude-yolo "claude --dangerously-skip-permissions"
    alias oc opencode
    command -qv nvim && alias vim nvim

    set -gx EDITOR nvim

    set -gx PATH bin $PATH
    set -gx PATH ~/bin $PATH
    set -gx PATH ~/.local/bin $PATH

    # Commands to run in interactive sessions can go here
    set -g fish_prompt_pwd_dir_length 1
    set -g theme_display_user yes
    set -g theme_hide_hostname no
    set -g theme_hostname always
    set -g theme_git_worktree_support yes
    set -g theme_display_docker_machine yes
    set -g theme_display_node yes
    set -g theme_powerline_fonts yes
    set -g theme_display_user ssh
    set -g theme_display_hostname ssh

    switch (uname)
        case Darwin
            source (dirname (status --current-filename))/config-osx.fish
        case Linux
            source (dirname (status --current-filename))/config-linux.fish
        case '*'
            source (dirname (status --current-filename))/config-windows.fish
    end
end

# pnpm end
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end

# opencode
fish_add_path /Users/caongoccuong/.opencode/bin

# Added by Antigravity
fish_add_path /Users/caongoccuong/.antigravity/antigravity/bin

# OpenClaw Completion
source "/Users/caongoccuong/.openclaw/completions/openclaw.fish"
