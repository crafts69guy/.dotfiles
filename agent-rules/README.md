# Agent Rules

Shared rules for multiple coding agents and tools. Keep this layer tool-neutral; put agent-specific instructions in thin adapters such as `AGENTS.md`, `CLAUDE.md`, or Codex skills.

## Routing

- General Markdown output: read `shared/markdown.md`.
- Research with citations or source claims: read `shared/research-citation.md`.
- Inkdrop v6 note-taking, Mermaid, note links, organization, or MCP usage: read `tools/inkdrop-v6/README.md`.
- React Native architecture, UI, navigation, state, testing, or Expo work: read `stacks/react-native/README.md`.
- Medusa commerce backend or storefront work: read `stacks/medusa/README.md`.
- Web3, DeFi, Solidity, BSC, or trading bot work: read `stacks/web3/README.md`.

## Maintenance Rules

- Keep shared rules as the single source of truth.
- Keep agent adapters short and point them here instead of duplicating policy.
- Split large rules by concern so agents can load only what the task needs.
- Prefer examples in task-specific files, not global adapters.
