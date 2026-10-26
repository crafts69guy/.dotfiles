function cyp --description "orc claude --yolo --pair: Codex implementer pane beside you, no permission prompts"
    if test "$HERDR_ENV" != 1
        echo "cyp: needs herdr (HERDR_ENV=1)" >&2
        return 1
    end
    orc claude --yolo --pair $argv
end
