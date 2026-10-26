function cyp --description "claude yolo pair (orc claude --yolo --pair): Codex implementer pane beside you"
    # Pair mode is silently off outside herdr, so fail loudly instead.
    if test "$HERDR_ENV" != 1
        echo "cyp: needs herdr (HERDR_ENV=1)" >&2
        return 1
    end
    orc claude --yolo --pair $argv
end
