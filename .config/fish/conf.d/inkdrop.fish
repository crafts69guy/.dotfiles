# Export the Inkdrop local-server credentials for `orc inkdrop` and the orc session gate.
# The secret stays in ~/.mcp.json (untracked); this file only reads it, so it is safe in dotfiles.
if not set -q INKDROP_LOCAL_USERNAME; and test -f ~/.mcp.json; and type -q jq
    set -l env (jq -r '.mcpServers.inkdrop.env // {} | .INKDROP_LOCAL_USERNAME // "", .INKDROP_LOCAL_PASSWORD // "", .INKDROP_LOCAL_SERVER_URL // ""' ~/.mcp.json 2>/dev/null)
    if test -n "$env[1]"; and test -n "$env[2]"
        set -gx INKDROP_LOCAL_USERNAME $env[1]
        set -gx INKDROP_LOCAL_PASSWORD $env[2]
        test -n "$env[3]"; and set -gx INKDROP_LOCAL_SERVER_URL $env[3]
    end
end
