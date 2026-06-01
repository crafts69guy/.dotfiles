# Full-Stack · Web3 · Systems Developer Preferences

**Profile**: MERN + Go + Rust · Web3/DeFi · AI Agents · Vim-first workflow
**Apply this guidance ALWAYS when assisting with code, architecture, or technical problems.**

---

## Core Identity

Full-stack developer across **four domains**: web apps (MERN), blockchain/DeFi (Go + Solidity), systems programming (Rust + Go), and AI agents. Primary editor is **Neovim** with **Inkdrop** for knowledge management. Terminal-centric workflow — prefer CLI over GUI.

Don't assume web-only — context may involve smart contracts, trading bots, CLI tools, MCP servers, or AI agent pipelines.

---

## Domain 1: Web Applications (MERN)

### Frontend — React 19+ / TypeScript
- Server Components, Actions, Suspense, concurrent rendering
- Modern hooks: `useActionState`, `useOptimistic`, `useTransition`, `useDeferredValue`
- **Tailwind CSS** with responsive design and dark mode
- **React Query/TanStack Query** for server state, **Zustand** for client state
- Optimistic updates, error boundaries, lazy loading, code splitting
- WCAG 2.1 AA, ARIA patterns, keyboard navigation
- **Next.js 15+** when SSR/SSG needed · **Framer Motion** for animations

### Backend — Node.js / Express / TypeScript
- REST with proper resource modeling, cursor-based pagination
- **Prisma ORM** with MongoDB · **Redis** for caching
- JWT/OAuth 2.0, RBAC · Structured logging with correlation IDs
- Circuit breaker, retry with exponential backoff, timeout management
- Docker-ready, GitHub Actions CI/CD · OpenAPI/Swagger docs

### Full-Stack Integration
- Shared TypeScript types from backend schemas
- Error format: `{ code, message, details }` · Proper HTTP status codes
- WebSocket/SSE for real-time · Never use `any` without justification

---

## Domain 2: Web3 / DeFi / Blockchain

### Smart Contracts — Solidity
- ERC-20/BEP-20 on **BSC (BNB Chain)** · OpenZeppelin base
- Tax mechanisms, anti-whale, owner controls
- **Foundry** preferred (Hardhat when needed) · Gas optimization
- Reentrancy protection · Honeypot/rug pull detection

### Trading Bots & DeFi — Go
- **Go 1.23+** · `go-ethereum`/`ethclient` for chain interaction
- BSC mempool monitoring, copy trading, DEX sniping
- Telegram bot interface · WebSocket to PancakeSwap / Four.meme
- `slog` structured logging · Graceful shutdown · Context propagation

### DeFi Patterns
- Bonding curves · DEX router (PancakeSwap V2/V3)
- Token approvals, slippage protection · MEV awareness
- ABI parsing, event log decoding

---

## Domain 3: Systems & Performance (Rust + Go)

### Rust
- `tokio` async · `serde` serialization · `thiserror`/`anyhow` errors
- `clap` CLI · Performance-critical components, data pipelines
- `clippy::pedantic` · Proper `Result<T, E>` propagation

### Go (beyond Web3)
- CLI tools (`cobra`/`viper`), microservices, concurrent workers
- Goroutines + channels · Interface-driven design · `context.Context` everywhere

### Shared Principles
- Zero-copy where possible · Connection pooling · Benchmark before optimize
- Profiling: pprof (Go), flamegraph (Rust)

---

## Domain 4: AI Agents & Automation

- Claude API (tool use, function calling, streaming)
- Multi-step agent workflows with tool chaining and reflection loops
- MCP server development (client + server)
- Agentic coding: Claude Code, plan → execute → verify
- RAG pipelines: embedding, vector search, context assembly
- LLM orchestration: routing, fallback, cost-aware model selection
- Telegram bots as control interfaces · Webhook-driven event processing
- Agent-to-agent communication patterns

---

## Dev Environment

- **Neovim**: Telescope, LSP (TS/Go/Rust/Solidity), custom plugins (ai-plans.nvim)
- **Claude Code** for agentic coding alongside Neovim
- **Inkdrop**: Project planning, sprint tracking, research notes (Vietnamese + English)
- **Toolchain**: TypeScript 5.x+ strict, ESLint+Prettier, golangci-lint, clippy, Docker, GitHub Actions, Husky

---

## Inkdrop Note-Taking

- For Inkdrop note creation, Mermaid editing, note linking, organization, or MCP workflows, use the `$inkdrop-note-taking` skill and the shared dotfiles rule pack at `agent-rules/tools/inkdrop-v6/README.md`.
- For cross-agent conventions beyond Inkdrop, use `agent-rules/README.md` as the shared routing index instead of duplicating rules here.

---

## How Claude Should Respond

### Always
- Infer domain from context (web, Web3, systems, AI agents)
- Production-ready code with proper error handling and types
- TypeScript types / Go interfaces / Rust traits at boundaries
- Handle edge cases · Security implications (especially Web3 fund safety)
- Testing strategy included · Trade-offs explained
- Use Vietnamese when I write in Vietnamese
- Vim-friendly formatting (no weird breaks in terminal)

### Never
- Hardcode secrets, private keys, mnemonics
- `any` (TS), `interface{}` without reason (Go), `unwrap()` in prod (Rust)
- Skip error handling · N+1 queries · Ignore gas costs
- Untestable code · Mixed concerns in single files

### Ask Clarification When
- Domain ambiguous (web vs Web3 vs systems vs AI)
- Multiple approaches with different trade-offs
- Smart contract changes affecting fund safety
- Performance/scale implications unclear

---

## Tech Stack Summary

| Domain | Languages | Key Tools |
|--------|-----------|-----------|
| Frontend | TypeScript, React 19+ | Next.js, Tailwind, React Query, Zustand |
| Backend | TypeScript, Node.js | Express, Prisma, MongoDB, Redis |
| Web3 | Solidity, Go | go-ethereum, Foundry, BSC/EVM |
| Systems | Go, Rust | tokio, cobra, slog |
| AI | TypeScript, Go | Claude API, MCP, Claude Code, Telegram Bot |
| DevTools | — | Neovim, Docker, GitHub Actions, Inkdrop |

---

## Shell Preference

- My interactive terminal shell is fish.
- Prefer fish-compatible syntax in user-facing commands and explanations.
- Avoid bash/zsh-only syntax unless it is required by a specific tool or script.
- For persistent environment variables in fish, use `set -gx NAME value`.
- For one-off environment variables, use `env NAME=value command`.
- For fish config snippets, use fish syntax and place reusable functions under `.config/fish/functions/`.
- If an agent execution tool internally runs zsh/bash, explain that separately while keeping commands meant for me fish-friendly.

---
