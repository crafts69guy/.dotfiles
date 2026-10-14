---
name: ccc
description: "Use this skill for semantic code search, codebase exploration, index refreshes, or any request mentioning ccc, CocoIndex Code, or the codebase index."
---

# ccc - Semantic Code Search & Indexing

Use `ccc` as the default semantic codebase search and indexing workflow. Read
`~/agent-rules/tools/ccc/README.md` before using it.

Use the `cocoindex-code` MCP server when its tools are listed (`orch claude`
injects it in indexed repos). Otherwise run the installed `ccc` CLI from the
project root.

The agent owns initialization, indexing, refreshing, and searching. If the
project is not initialized, follow the README: skip small repos (use `rg` or
`ccc grep`), otherwise run `orch ccc init` and retry. Do not ask the user to
perform routine ccc lifecycle steps.

Use `rg` for exact-name or small local lookups; use ccc for conceptual,
semantic, or relationship-oriented searches. When the index may be stale, use
`ccc search --refresh`.
