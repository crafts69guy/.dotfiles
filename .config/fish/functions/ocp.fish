function ocp --description "orc claude --pair: Codex implementer pane beside you, with permission prompts"
    if test "$HERDR_ENV" != 1
        echo "ocp: needs herdr (HERDR_ENV=1)" >&2
        return 1
    end
    orc claude --pair $argv
end
