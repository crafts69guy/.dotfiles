function cyl --description "claude yolo; --wf enables the orchestra workflow (ORCH=1; ORCH_DEV=1 loads the plugin from \$ORCH_DIR)"
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
        set -l plugin
        # Released plugin by default; ORCH_DEV=1 tests the local checkout instead.
        test "$ORCH_DEV" = 1; and test -n "$ORCH_DIR"; and set plugin --plugin-dir $ORCH_DIR
        ORCH=1 claude --dangerously-skip-permissions --model opus $plugin $args
    else
        claude --dangerously-skip-permissions $args
    end
end
