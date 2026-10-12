#!/usr/bin/env fish
# Run: fish .config/fish/tests/cyl.fish
set -l here (path resolve (path dirname (status filename)))
source $here/../functions/cyl.fish
source $here/../functions/cdx.fish

function claude
    set -g claude_argv $argv
    set -g claude_orch "$ORCH"
end

function codex
    set -g codex_argv $argv
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
set -l orch $tmp/orchestra
mkdir -p $orch/bin
printf '#!/bin/sh\necho "orch-codex $*"\n' >$orch/bin/orch-codex
chmod +x $orch/bin/orch-codex

# cyl
set -e ORCH_DIR
cyl -p hi
test "$claude_argv" = "--dangerously-skip-permissions -p hi"; and test -z "$claude_orch"
check "cyl: plain passes args, no ORCH"

set -g claude_argv
cyl --wf -p hi
test "$claude_argv" = "--dangerously-skip-permissions --model opus -p hi"; and test "$claude_orch" = 1
check "cyl --wf without ORCH_DIR: ORCH=1, no --plugin-dir, --wf removed"

set -gx ORCH_DIR $orch
cyl --wf -p hi
test "$claude_argv" = "--dangerously-skip-permissions --model opus --plugin-dir $orch -p hi"; and test "$claude_orch" = 1
check "cyl --wf with ORCH_DIR: --plugin-dir added, args passed through"

set -g claude_orch
cyl -p hi
test "$claude_argv" = "--dangerously-skip-permissions -p hi"; and test -z "$claude_orch"
check "cyl plain ignores ORCH_DIR and does not set ORCH"

# cdx
cdx -m x
test "$codex_argv" = "--dangerously-bypass-approvals-and-sandbox -m x"
check "cdx: plain runs codex with yolo flag"

set -l out (cdx --wf -m x)
test $status -eq 0; and test "$out" = "orch-codex --dangerously-bypass-approvals-and-sandbox -m x"
check "cdx --wf: runs orch-codex with yolo flag and args, --wf removed"

set -g codex_argv
set -e ORCH_DIR
set -l err (cdx --wf 2>&1)
test $status -eq 1; and string match -q "*ORCH_DIR*" -- $err; and test -z "$codex_argv"
check "cdx --wf errors when ORCH_DIR unset"

set -gx ORCH_DIR $tmp/missing
set err (cdx --wf 2>&1)
test $status -eq 1; and string match -q "*orch-codex*" -- $err; and test -z "$codex_argv"
check "cdx --wf errors when launcher missing"

chmod -x $orch/bin/orch-codex
set -gx ORCH_DIR $orch
cdx --wf >/dev/null 2>&1
test $status -eq 1
check "cdx --wf errors when launcher not executable"

rm -rf $tmp
test $fails -eq 0
