if status is-interactive
    # Run home brew
    set -gx PATH /opt/homebrew/bin $PATH

    # set fish_greeting ""

    set -gx TERM tmux-256color

    # aliases
    alias ls "ls -p -G"
    alias la "ls -A"
    alias ll "ls -l"
    alias lla "ll -A"
    alias g git
    # alias ga git add
    # alias gc git commit
    # alias gp git push
    alias c claude
    alias claude-yolo "claude --dangerously-skip-permissions"
    alias oc opencode
    command -qv nvim && alias vim nvim

    set -gx EDITOR nvim

    set -gx PATH bin $PATH
    set -gx PATH ~/bin $PATH
    set -gx PATH ~/.local/bin $PATH

    # Commands to run in interactive sessions can go here
    set -g theme_color_scheme terminal-dark
    set -g fish_prompt_pwd_dir_length 1
    set -g theme_display_user yes
    set -g theme_hide_hostname no
    set -g theme_hostname always
    # set -g theme_display_git no
    # set -g theme_display_git_dirty no
    # set -g theme_display_git_untracked no
    # set -g theme_display_git_ahead_verbose yes
    # set -g theme_display_git_dirty_verbose yes
    # set -g theme_display_git_stashed_verbose yes
    # set -g theme_display_git_default_branch yes
    # set -g theme_git_default_branches master main
    # set -g theme_git_worktree_support yes
    # set -g theme_use_abbreviated_branch_name yes
    # set -g theme_display_vagrant yes
    # set -g theme_display_docker_machine no
    # set -g theme_display_k8s_context yes
    # set -g theme_display_hg yes
    # set -g theme_display_virtualenv no
    # set -g theme_display_nix no
    # set -g theme_display_ruby no
    # set -g theme_display_node yes
    # set -g theme_display_user ssh
    # set -g theme_display_hostname ssh
    # set -g theme_display_vi yes
    # set -g theme_display_date no
    # set -g theme_display_cmd_duration yes
    # set -g theme_title_display_process yes
    # set -g theme_title_display_path no
    # set -g theme_title_display_user yes
    # set -g theme_title_use_abbreviated_path no
    # set -g theme_date_format "+%a %H:%M"
    # set -g theme_date_timezone America/Los_Angeles
    # set -g theme_avoid_ambiguous_glyphs no
    # set -g theme_powerline_fonts yes
    # set -g theme_nerd_fonts yes
    # set -g theme_show_exit_status yes
    # set -g theme_display_jobs_verbose yes
    # set -g default_user your_normal_user
    # set -g theme_color_scheme nord
    # set -g fish_prompt_pwd_dir_length 0
    # set -g theme_project_dir_length 1
    # set -g theme_newline_cursor yes
    # set -g theme_newline_prompt '$ '

    switch (uname)
        case Darwin
            source (dirname (status --current-filename))/config-osx.fish
        case Linux
            source (dirname (status --current-filename))/config-linux.fish
        case '*'
            source (dirname (status --current-filename))/config-windows.fish
    end
end

# pnpm
set -gx PNPM_HOME /Users/caongoccuong/Library/pnpm
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# opencode
fish_add_path /Users/caongoccuong/.opencode/bin

# Added by Antigravity
fish_add_path /Users/caongoccuong/.antigravity/antigravity/bin
