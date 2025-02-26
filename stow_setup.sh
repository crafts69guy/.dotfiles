#!/usr/bin/env bash

# Stow dotfiles
stow -Rv .

# Run Tide configuration
fish ~/.dotfiles/.config/fish/scripts/tide_setup.fish
