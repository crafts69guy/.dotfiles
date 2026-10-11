#!/usr/bin/env fish
# Run: fish .config/fish/tests/cyw.fish
set -l here (path resolve (path dirname (status filename)))
source $here/../functions/cyw.fish

function cyl
    set -g cyl_called "$argv"
end

function check -a desc
    if test $status -eq 0
        echo "ok   $desc"
    else
        echo "FAIL $desc"
        set -g fails (math $fails + 1)
    end
end
set -g fails 0

set -l tmp (mktemp -d)
set -l repo $tmp/repo
git init -q -b production $repo
git -C $repo -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
git -C $repo branch existing
cd $repo

set -g cyl_called
cyw feat-x >/dev/null 2>&1
test (pwd) = (path resolve $tmp/wt/feat-x); and test "$cyl_called" = --wf
check "creates new branch worktree, cds, runs cyl --wf"
test (git rev-parse --abbrev-ref HEAD) = feat-x; and test (git rev-parse HEAD) = (git -C $repo rev-parse production)
check "new branch is based on production"

cd $tmp/wt/feat-x
cyw existing >/dev/null 2>&1
test (pwd) = (path resolve $tmp/wt/existing); and test (git rev-parse --abbrev-ref HEAD) = existing
check "checks out existing branch; no nesting when run inside a worktree"

cd $repo
set -g cyl_called
set -l err (cyw feat-x 2>&1)
test $status -ne 0; and string match -q "*already exists*" -- $err; and test -z "$cyl_called"; and test (pwd) = $repo
check "errors clearly when worktree exists"

cyw >/dev/null 2>&1
test $status -ne 0
check "errors without argument"

cd $tmp
cyw x >/dev/null 2>&1
test $status -ne 0
check "errors outside a git repo"

source $here/../completions/cyw.fish
cd $repo
set -l comps (complete -C 'cyw ')
contains existing $comps; and contains production $comps
check "completes local branch names"

rm -rf $tmp
test $fails -eq 0
