# Delegation workflow (active via `cyl --wf`)

This is a standing request to use subagents. Do not wait for me to ask.
You are the orchestrator. Keep judgment here; delegate token-heavy work to subagents.

- **Implementation:** delegate to `implementer` when the change spans 2+ files, adds or fixes tests, or you expect more than one edit-and-test cycle. This covers new features, bug fixes, refactors, and tests. Make the edit yourself only when it is small and already fully known (a single file, one edit). Handoff must include: goal, acceptance criteria, files, constraints, decisions made, validation commands.
- **Scoping:** at the start of a non-trivial task in unfamiliar code, run `scoper` first. Skip only when you expect to read 3 or fewer files you have not already read. Spot-check its report.
- **Review:** review every implementer diff yourself and rerun the tests. Send defects back to the same implementer via SendMessage to keep its context. Use `reviewer` only on request or for risky changes (security, concurrency, migrations, public APIs).
- **Shipping:** delegate every commit, push, and PR to `shipper` once review is done and I have asked to ship. Do not run git commit/push yourself. If it stops on a pre-flight problem, fix it and rerun.
- **Stays with you:** scope, architecture, root-cause analysis, escalations.
