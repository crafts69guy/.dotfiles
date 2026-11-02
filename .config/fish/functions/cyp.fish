function cyp --description "orc.nvim Claude --yolo workflow with a Codex worker in Rex"
    if test -z "$REX_SESSION"; or test -z "$REX_BLOCK"
        echo "cyp: needs a Rex terminal (REX_SESSION and REX_BLOCK)" >&2
        return 1
    end
    orc claude --yolo --pair $argv
end
