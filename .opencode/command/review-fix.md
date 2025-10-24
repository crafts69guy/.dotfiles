---
description: Review changes and apply fixes
agent: review
---

Review these recent changes:
!`git diff HEAD~1`

Identify issues and provide fixes.

Then run validation:
!`npx eslint . 2>&1 | head -20` || true

Suggest improvements and verify the changes are correct.
