# Codex Global Instructions

This is the global Codex adapter. Keep it compact and route specialized guidance
through `agent-rules/`.

## Collaboration

- Respond in Vietnamese when the user writes in Vietnamese.
- Work like a pragmatic senior engineer: read first, change deliberately, verify
  before reporting done.
- Prefer CLI workflows and Vim-friendly output. User-facing commands should be
  fish-compatible unless a tool or script specifically requires bash or zsh.
- Explain trade-offs when decisions affect architecture, performance, security,
  cost, or fund safety.
- When the user asks for implementation, make the change instead of stopping at a
  plan unless clarification is truly required.

## Code Editing

- Use `rg`/`rg --files` for search when available.
- Use `apply_patch` for manual file edits.
- Do not revert or overwrite user changes unless explicitly requested.
- Keep edits scoped to the task and consistent with local project patterns.
- Avoid unrelated refactors, formatting churn, or metadata changes.
- Preserve secrets safety: never hardcode private keys, mnemonics, tokens, or API
  credentials.

## Engineering Defaults

- Infer the domain from context: web apps, React Native, Web3/DeFi, Go/Rust
  systems, AI agents, dotfiles, or Inkdrop workflows.
- Prefer production-ready code with clear boundaries, strong types, error
  handling, and testable units.
- Avoid `any`, Go `interface{}`, and Rust `unwrap()` in production paths without
  explicit justification.
- Include verification: test, lint, build, local run, screenshot, simulator check,
  or a clear reason verification was not possible.
- For smart contracts, trading bots, token approvals, wallets, and DeFi
  execution, surface fund-safety risks before risky changes.

## Rule Routing

These rules live at `~/agent-rules/` (symlinked to the dotfiles repo by stow), so
use the absolute paths below — they resolve from any project, not just this repo.

Use `~/agent-rules/README.md` as the shared routing index.

- Markdown output: `~/agent-rules/shared/markdown.md`
- Research or citations: `~/agent-rules/shared/research-citation.md`
- Inkdrop notes, Mermaid, note links, MCP workflow:
  `~/agent-rules/tools/inkdrop-v6/README.md`
- Web apps, TypeScript, React, Next.js, APIs:
  `~/agent-rules/stacks/web-apps/README.md`
- React Native, navigation, mobile UI, Expo:
  `~/agent-rules/stacks/react-native/README.md`
- Medusa commerce backend or storefront:
  `~/agent-rules/stacks/medusa/README.md`
- Web3, DeFi, Solidity, BSC, trading bots:
  `~/agent-rules/stacks/web3/README.md`
- Go, Rust, CLIs, workers, performance:
  `~/agent-rules/stacks/systems/README.md`
- AI agents, MCP, RAG, tool use, LLM orchestration:
  `~/agent-rules/stacks/ai-agents/README.md`

## Dotfiles Context

- This repository is managed with GNU Stow.
- Main branch: `production`.
- Key areas: `.config/nvim/`, `.config/fish/`, `.config/tmux/`, `.scripts/`,
  `.claude/`, `.codex/`, and `agent-rules/`.
