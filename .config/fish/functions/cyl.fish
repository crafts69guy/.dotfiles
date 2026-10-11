function cyl --description "claude yolo; --wf enables the subagent workflow"
    set -l wf ~/.claude/workflows/wf
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
        claude --dangerously-skip-permissions --model opus \
            --agents $wf/agents.json \
            --append-system-prompt (string collect < $wf/rules.md) $args
    else
        claude --dangerously-skip-permissions $args
    end
end
