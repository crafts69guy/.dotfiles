# AI Agent Stack Rules

Use these shared rules for AI agents, MCP servers, tool use, RAG, and LLM
orchestration.

- Define the agent loop explicitly: inputs, state, tools, decision points,
  stop conditions, and failure handling.
- Keep tool schemas narrow, typed, and auditable; never expose secrets through
  tool arguments, logs, traces, or memory.
- Separate durable memory, task scratch state, and retrieved context.
- Prefer deterministic routing and fallback policies before adding reflection or
  multi-agent complexity.
- Track cost, latency, model choice, retries, and user-visible failure modes.
- Test tool-call validation, prompt injection boundaries, malformed tool output,
  and recovery from partial failures.
