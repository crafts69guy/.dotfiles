# XDG base dir — make tools (lazygit, etc.) read configs from ~/.config on macOS
set -gx XDG_CONFIG_HOME $HOME/.config

# React Native: force New Architecture for CocoaPods and Xcode builds
set -gx RCT_NEW_ARCH_ENABLED 1
set -gx REACT_TERMINAL Ghostty

# User-installed CLIs must also be available to non-interactive runners such as Codex.
fish_add_path $HOME/.local/bin

# Android development
# Gradle 9 needs Java 17–21; macOS default is JDK 26 and Homebrew openjdk@17 is
# keg-only (not registered with /usr/libexec/java_home), so pin it explicitly.
set -gx JAVA_HOME /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
if test -d $HOME/Library/Android/sdk
    set -gx ANDROID_HOME $HOME/Library/Android/sdk
    fish_add_path $ANDROID_HOME/emulator $ANDROID_HOME/platform-tools
end

# Local secrets (not tracked by git)
test -f (dirname (status --current-filename))/config-local.fish
and source (dirname (status --current-filename))/config-local.fish

# fnm - Fast Node Manager (must init first)
# Let fnm own the Node/Corepack PATH so a stale multishell cannot run a newer
# Corepack with an older Node runtime.
if status is-interactive && command -q fnm
    # fnm's initial PWD hook runs while this script is sourced. Keep that
    # bootstrap quiet, then restore the user's log level for interactive use.
    set -l fnm_log_level $FNM_LOGLEVEL
    # Nested shells (tmux, herdr, claude) inherit the parent's multishell; drop it
    # so only this shell's multishell stays on PATH.
    set -gx PATH (string match -v -- '*/fnm_multishells/*' $PATH)
    fnm env --log-level quiet --use-on-cd --corepack-enabled --shell fish | source
    if set -q fnm_log_level[1]
        set -gx FNM_LOGLEVEL $fnm_log_level
    else
        set -e FNM_LOGLEVEL
    end
    if not fnm use --silent-if-unchanged >/dev/null 2>&1
        fnm use --silent-if-unchanged default >/dev/null
    end
end

# pnpm
set -gx PNPM_HOME '/Users/caongoccuong/Library/pnpm'
if test "$PATH[1]" != "$PNPM_HOME/bin"
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end

# opencode
fish_add_path /Users/caongoccuong/.opencode/bin

# Added by Antigravity
fish_add_path /Users/caongoccuong/.antigravity/antigravity/bin
