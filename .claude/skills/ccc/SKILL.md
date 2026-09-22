---
name: ccc
description: "Use this skill for semantic code search, codebase exploration, index refreshes, or any request mentioning ccc, CocoIndex Code, or the codebase index."
---

# ccc - Semantic Code Search & Indexing

Use `ccc` as the default semantic codebase search and indexing workflow. Read
`~/agent-rules/tools/ccc/README.md` before using it.

Claude Code should prefer the `cocoindex-code` MCP server when its tools are
available. If the MCP server is unavailable, run the installed `ccc` CLI from
the project root.

The agent owns initialization, indexing, refreshing, and searching. If the
project is not initialized, run `ccc init` and `ccc index` before retrying the
original request. Do not ask the user to perform routine ccc lifecycle steps.

Use `rg` for exact-name or small local lookups; use ccc for conceptual,
semantic, or relationship-oriented searches. After significant code changes,
refresh the index before relying on search results.
