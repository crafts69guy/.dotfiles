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