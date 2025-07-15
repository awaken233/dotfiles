# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive personal dotfiles repository using **Dotbot** for automated configuration management. The setup creates symbolic links from the repository to appropriate locations in the home directory.

## Essential Commands

### Setup and Installation
```bash
./install                    # Main installation script - sets up all dotfiles via Dotbot
git submodule update --init  # Initialize Dotbot submodule if needed
```

### Configuration Management
- All configuration files are stored in the repository root
- Symbolic links are managed automatically by Dotbot via `install.conf.yaml`
- No manual linking required - everything is automated through the install script

## Architecture and Key Components

### Core Configuration Framework
- **Automation**: Dotbot (git submodule) handles all symlinking and directory creation
- **Configuration**: `install.conf.yaml` defines the mapping of files to target locations
- **Installation**: Single `./install` script manages the entire setup process

### Major Configuration Areas

#### Shell Environment (`zshrc`)
- Oh-My-Zsh with custom plugins (syntax highlighting, autosuggestions, history search)
- Starship prompt integration
- Extensive development aliases (proxy, git, kubectl, maven)
- Custom functions: `rgfzf()` for ripgrep+fzf search, `lg()` for lazygit, `project_lazygit()`
- FZF integration with bat for file previews

#### Git Workflow (`gitconfig`, `lazygit_config`)
- Delta pager for enhanced diffs
- Conditional includes for work/personal configurations
- LazyGit with custom IDE integration commands (IntelliJ, Cursor)
- Global gitignore handling IDE files and build artifacts

#### Editor Configurations
- **LazyVim**: Full Neovim setup in `lazyvim/` directory with custom plugins
- **Traditional Vim**: `vimrc` with vim-plug plugin manager
- **IntelliJ IDEA**: `ideavimrc` for vim keybindings in IDE
- **Obsidian**: Highly customized `obsidianvimrc` with extensive vim configuration for note-taking

#### Terminal and File Management
- **Tmux**: True color support, vi key bindings (`tmuxconf`)
- **LF File Manager**: Configuration and preview scripts in `lf/` directory
- **Karabiner Elements**: macOS keyboard customization in `karabiner/` directory

### File Organization Principles
- Configuration files are stored flat in repository root (e.g., `zshrc`, `gitconfig`)
- Directory-based configs use subdirectories (e.g., `lazyvim/`, `lf/`, `karabiner/`)
- Target locations span user home directory and platform-specific config directories
- Obsidian configuration targets document-specific location

### Development Environment Focus
This setup is optimized for:
- Modern CLI development workflow with ripgrep, fzf, bat, delta
- Multiple vim/neovim environments for different contexts
- Git-centric development with enhanced diff viewing and lazygit integration
- macOS development with native tool integration
- Cross-editor consistency with vim keybindings in multiple applications

### Key Integration Points
- FZF + Ripgrep + Bat create unified search/preview experience
- Starship provides consistent prompt across terminals
- Delta provides enhanced git diff viewing across git and lazygit
- Vim configurations maintain consistency across Neovim, traditional Vim, IntelliJ, and Obsidian
- Shell aliases provide quick access to containerized and proxied development tools

### Configuration Language Notes
- Comments and documentation use both Chinese and English
- Chinese text typically provides context for specific customizations
- Configuration follows modern best practices for each tool