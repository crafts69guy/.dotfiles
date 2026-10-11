function cyw --description "new git worktree in ../wt/<name> from production, then cyl --wf"
    if test (count $argv) -ne 1
        echo "usage: cyw <branch>" >&2
        return 1
    end
    set -l name $argv[1]
    # Main worktree root, so running cyw inside a worktree doesn't nest ../wt
    set -l common (git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    or begin
        echo "cyw: not in a git repository" >&2
        return 1
    end
    set -l dir (path dirname $common)/../wt/$name
    if test -e $dir
        echo "cyw: worktree already exists: "(path resolve $dir) >&2
        return 1
    end
    if git show-ref --verify --quiet refs/heads/$name
        git worktree add $dir $name
    else
        git worktree add -b $name $dir production
    end
    or return
    cd $dir; and cyl --wf
end
