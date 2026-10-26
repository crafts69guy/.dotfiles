function ocp --description "orc claude --pair (with permission prompts): Codex implementer pane beside you"
    if test "$HERDR_ENV" != 1
        echo "ocp: needs herdr (HERDR_ENV=1)" >&2
        return 1
    end
    orc claude --pair $argv
end
