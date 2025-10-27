---
description: Fix issue and run lint/tests
agent: general
---

Fix the reported issue.

Usage: /fix-and-verify [with-tests|no-tests]
Example: /fix-and-verify with-tests

$ARGUMENTS

If with-tests: Run full test suite and show results
If no-tests: Only run linting (npx eslint .)

Always run:

- Linting: `npx eslint .`

Show before/after comparison and verify the fix works.
