---
description: Analyze and debug the issue
agent: general
---

Issue: $ARGUMENTS

Recent git changes:
!`git log --oneline -5`

Current linting status:
!`npx eslint . 2>&1 | head -30` || true

Find the root cause and suggest a fix with step-by-step instructions.
