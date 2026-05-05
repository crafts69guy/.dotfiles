# AGENTS.md - Development Guidelines

## Build/Lint/Test Commands

### Linting
- **ESLint**: `npx eslint .` (for JS/TS files)
- **Biome**: `npx biome check .` (alternative linter, config in .config/biome/biome.json.backup)
- **Luacheck**: For Lua files (configured in Neovim LSP)

### Formatting
- **Prettier**: `npx prettier --write .` (JS/TS/JSON/CSS/HTML/MD)
- **Stylua**: For Lua files (configured in Neovim Conform)

### Testing
- No explicit test framework configured
- Run linting to catch issues: `npx eslint .`

## Code Style Guidelines

### JavaScript/TypeScript
- **ESLint config**: .eslintrc.js with TypeScript + React + React Hooks
- **Prettier config**: .prettierrc (semicolons, single quotes, 100 width, 2 spaces)
- **Imports**: Use ES6 imports, group by external/internal, sort alphabetically
- **Types**: Use TypeScript interfaces for objects, avoid `any`, explicit return types optional
- **Naming**: camelCase for variables/functions, PascalCase for components/classes
- **Error handling**: Use try/catch, avoid console.log in production code

### Lua (Neovim config)
- **Formatter**: Stylua with 2-space indentation
- **Style**: Follow Lua LSP diagnostics, avoid unused variables

### Shell Scripts
- **Fish shell**: Use functions in .config/fish/, follow POSIX conventions where applicable
- **Bash scripts**: Use .scripts/ directory, include shebang

### Git
- **Commits**: Use cz-git for conventional commits
- **Branch**: Main branch is `production`
- **Workflow**: GNU Stow for dotfile management

### General
- **Line endings**: LF (Unix)
- **Encoding**: UTF-8
- **No trailing whitespace**
- **No console/debugger in production code**

## Inkdrop Note-Taking

- For Inkdrop note creation, Mermaid editing, note linking, organization, or MCP workflows, read `agent-rules/tools/inkdrop-v6/README.md` from this dotfiles repo and then only the referenced rule files needed for the task.
- For cross-agent conventions beyond Inkdrop, use `agent-rules/README.md` as the shared routing index instead of duplicating rules in this file.

## Agent Collaboration

### Codex / Claude Role
- Act as a trusted collaborator first: friend, solution architect, and senior React Native engineer
- Communicate directly and pragmatically, with architecture-level reasoning when trade-offs matter
- Prioritize production-ready solutions, clear boundaries, and maintainable implementation details
- When working on React Native projects, default to senior-level mobile architecture, state, navigation, performance, and DX considerations
- Behave like an ongoing engineering partner, not just a code generator
