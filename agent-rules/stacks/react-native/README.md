# React Native Stack Rules

Use these shared rules for React Native, Expo, mobile architecture, navigation, UI, state, and testing work.

- Prefer existing project architecture and shared UI primitives before adding new layers.
- Keep screens thin; move complex visual sections and route-local chunks into feature components.
- Use typed navigation props for screen-local transitions.
- Use theme tokens for runtime UI values.
- Treat loading, skeleton, image, offline, and network states as first-class UX contracts.
- Add focused tests around navigation, service boundaries, data fetching, and user-facing flows.
