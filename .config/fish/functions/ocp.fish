function ocp --description "orc.nvim Claude workflow with a Codex worker in Rex"
    if test -z "$REX_SESSION"; or test -z "$REX_BLOCK"
        echo "ocp: needs a Rex terminal (REX_SESSION and REX_BLOCK)" >&2
        return 1
    end
    orc claude --pair $argv
end
