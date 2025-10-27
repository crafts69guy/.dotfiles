---
description: Create a new React component
agent: build
model: anthropic/claude-3-5-sonnet-20241022
---

I'll help you create a new React component. Let me ask you some questions first:

1. **Component Name**: $ARGUMENTS (or tell me the name if not provided)

Before I create the component, please clarify:

2. **Where should I place the file?**
   - Option A: `src/components/$ARGUMENTS.tsx` (default location)
   - Option B: `src/components/ui/$ARGUMENTS.tsx` (UI components)
   - Option C: `src/components/layout/$ARGUMENTS.tsx` (Layout components)
   - Option D: Custom path (please specify)

3. **Should I include the following?**
   - Storybook story file (.stories.tsx)?
   - Unit tests (.test.tsx)?
   - Or both?

Once you confirm your preferences, I'll create:

- The React component file with TypeScript support and proper prop typing
- Storybook story if requested (following patterns from @src/components/)
- Unit tests if requested (following patterns from @src/components/**tests**/)

All files will follow your project's existing conventions and structure.
