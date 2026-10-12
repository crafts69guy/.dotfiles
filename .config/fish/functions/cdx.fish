function cdx --description "codex yolo; --wf enables the orchestra workflow"
    set -l args
    set -l use_wf 0
    for a in $argv
        if test "$a" = --wf
            set use_wf 1
        else
            set -a args $a
        end
    end
    if test $use_wf = 1
        if test -z "$ORCH_DIR"
            echo "cdx: ORCH_DIR is not set" >&2
            return 1
        end
        if not test -x $ORCH_DIR/bin/orch-codex
            echo "cdx: $ORCH_DIR/bin/orch-codex is not executable" >&2
            return 1
        end
        $ORCH_DIR/bin/orch-codex --dangerously-bypass-approvals-and-sandbox $args
    else
        codex --dangerously-bypass-approvals-and-sandbox $args
    end
end
