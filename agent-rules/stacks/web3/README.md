# Web3 Stack Rules

Use these shared rules for Solidity, EVM/BSC, DeFi, trading bots, and chain integrations.

- Never hardcode or expose private keys, mnemonics, API secrets, or signing secrets.
- Treat fund movement, approvals, custody, slippage, and replay protection as high-risk.
- Prefer audited libraries such as OpenZeppelin for standard token/security primitives.
- Keep cryptographic signing and privileged operations server-side or wallet-owned, not mobile-app-owned.
- For bots and chain services, use structured logging, context cancellation, backoff, and graceful shutdown.
- Test edge cases around reentrancy, replay, failed transactions, reverted calls, duplicate events, and chain reorgs.
