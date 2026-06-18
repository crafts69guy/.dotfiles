# CLAUDE.md - Dotfiles Management Guide

This file contains specific instructions for working with this dotfiles repository.

## Project Structure
- `.config/` - Application configurations (nvim, fish, tmux, etc.)
- `.scripts/` - Custom shell scripts
- `stow_setup.sh` - Main initialization script
- Configuration files: `.gitconfig`, `.zshrc`, `.czrc`

## Common Commands

### Dotfiles Management
```bash
# Apply all dotfiles using stow
stow -v .

# Remove all symlinks
stow -D .

# Restow (useful after changes)
stow -R .

# Apply specific configuration
stow -v .config

# Initialize everything
./stow_setup.sh
```

### Development Workflow
```bash
# Check git status
git status

# Stage changes
git add .

# Commit changes
git commit -m "description"

# Push to remote
git push origin production
```

### Testing Changes
```bash
# Verify shell configuration
echo $SHELL

# Test nvim installation
nvim --version

# Restart shell to apply changes
exec fish
```

## Inkdrop Note-Taking

- For Inkdrop note creation, Mermaid editing, note linking, organization, or MCP workflows, read `~/agent-rules/tools/inkdrop-v6/README.md` and then only the referenced rule files needed for the task.
- For cross-agent conventions beyond Inkdrop, use `~/agent-rules/README.md` as the shared routing index instead of duplicating rules in this file.

## Key Files to Monitor
- `.config/nvim/` - Neovim configuration
- `.config/fish/config.fish` - Fish shell configuration
- `.config/tmux/tmux.conf` - Tmux configuration
- `.gitconfig` - Git configuration

## Notes
- Main branch: `production`
- Uses GNU Stow for symlink management
- Fish shell with Tide prompt configured
- Neovim with LazyVim setup
