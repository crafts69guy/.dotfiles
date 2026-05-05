# Inkdrop v6 Mermaid Rules

Reference basis: Inkdrop Markdown docs, the `inkdrop-mermaid` plugin docs, and Mermaid v11 behavior around unsupported Markdown list content in labels.

## Rules

- Use fenced blocks with the `mermaid` language identifier.
- Prefer `flowchart LR` or `flowchart TD` for new flow diagrams.
- Keep node and edge labels plain and short. Put long explanations in Markdown outside the diagram.
- Do not use Markdown bullets or numbered lists inside labels.
- Avoid edge labels like `|1. initiate payment|`; use `|initiate payment|`.
- Do not use literal `\n` in labels. Use `<br/>` for intended line breaks.
- Avoid emoji in labels. Use text such as `Critical:` or `High:` for severity.
- Quote complex labels with `["..."]`, but keep the content to plain text and `<br/>`.

## Preflight

- No `|1. ...|`, `|2. ...|`, `- `, `* `, or Markdown-list-shaped content inside labels.
- No literal `\n` inside labels.
- Multi-line labels use `<br/>`.
- Labels are concise enough to fit inside nodes.
- Dense diagrams are split into a small diagram plus a Markdown table/list.

## Safe Payment Flow

```mermaid
flowchart LR
  A[Mobile App] -->|initiate payment| B[Backend API]
  B -->|generate signed URL| C[Payment Gateway]
  C -->|redirect user| D[Bank or Wallet]
  D -->|payment result| C
  C -->|IPN webhook| B
  C -->|redirect user| A
  B -->|verified status| A

  style B fill:#4a4a8a,color:#fff
  style C fill:#2d7d46,color:#fff
```

## Safe Threat Model

```mermaid
flowchart TD
  T1["Critical: HashSecret Exposure<br/>Attacker extracts from APK or IPA"] -->|impact| I1["Forge arbitrary payment requests<br/>Sign fake returns as success"]
  T2["Critical: Amount Tampering<br/>Client sends amount=1"] -->|impact| I2["Pay tiny amount for any order"]
  T3["Critical: Signature Bypass<br/>Forged return URL params"] -->|impact| I3["Fake successful payment without paying"]
  T4["High: Duplicate IPN<br/>Gateway retry storm"] -->|impact| I4["Double ship or double credit loyalty"]
  T5["Critical: MITM on Payment Traffic<br/>SSL stripping attack"] -->|impact| I5["Intercept card or account data"]
  T6["Medium: Transaction Replay<br/>Reuse old valid signature"] -->|impact| I6["Re-trigger old payment as new"]
```

## Unsafe Patterns

```text
flowchart LR
  A -->|1. initiate payment| B
  B["Critical issue\nAttacker extracts secret"]
  C["- first risk
  - second risk"]
```

The numbered edge label can be parsed as a Markdown list, literal `\n` can render visibly, and bullet-like label content can trigger `Unsupported markdown: list`.
