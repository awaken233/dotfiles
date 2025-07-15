# Dotfiles

> **Other Languages:** [中文](README.zh-CN.md)

A comprehensive personal dotfiles repository using **Dotbot** for automated configuration management across multiple development environments.

## Features

- 🚀 **Automated Setup**: One-command installation using Dotbot
- 🔧 **Modern CLI Tools**: Integrated with ripgrep, fzf, bat, delta, and starship
- 🎨 **Multi-Editor Support**: Configurations for Neovim (LazyVim), Vim, IntelliJ IDEA, and Obsidian
- 🐚 **Enhanced Shell**: Zsh with Oh-My-Zsh, syntax highlighting, and custom aliases
- 📁 **File Management**: LF file manager with preview support
- 🔀 **Git Workflow**: LazyGit integration with enhanced diff viewing
- ⌨️ **Keyboard Optimization**: Karabiner Elements configuration for macOS
- 🖥️ **Terminal Multiplexing**: Tmux with vi keybindings and true color support

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install all configurations
./install
```

## Project Structure

```
.
├── install                 # Main installation script
├── install.conf.yaml      # Dotbot configuration
├── CLAUDE.md              # AI assistant guidance
├── dotbot/                # Dotbot submodule
│
├── Shell & Terminal
├── zshrc                  # Zsh configuration with Oh-My-Zsh
├── tmuxconf              # Tmux configuration
│
├── Git & Version Control
├── gitconfig             # Git configuration
├── gitignore_global      # Global gitignore
├── lazygit_config        # LazyGit configuration
│
├── Editors
├── lazyvim/              # Neovim (LazyVim) configuration
├── vimrc                 # Traditional Vim configuration
├── ideavimrc             # IntelliJ IDEA vim plugin
├── obsidianvimrc         # Obsidian vim plugin
│
├── Tools & Utilities
├── lf/                   # LF file manager configuration
└── karabiner/            # Karabiner Elements (macOS)
```

## Configuration Details

### Shell Environment (zshrc)

- **Framework**: Oh-My-Zsh with custom plugins
- **Plugins**: syntax-highlighting, autosuggestions, history-substring-search
- **Prompt**: Starship integration for modern prompt
- **Aliases**: Extensive development aliases for proxy, git, kubectl, maven
- **Functions**: Custom functions like `rgfzf()`, `lg()`, `project_lazygit()`
- **FZF Integration**: Enhanced with bat for file previews

### Git Workflow

- **Pager**: Delta for enhanced diff viewing
- **Configuration**: Conditional includes for work/personal setups
- **LazyGit**: Custom IDE integration commands
- **Global Ignore**: Handles IDE files and build artifacts

### Editor Configurations

#### Neovim (LazyVim)
- Full LazyVim setup with custom plugins
- Located in `lazyvim/` directory
- Modern Lua configuration

#### Traditional Vim
- Classic vim configuration with vim-plug
- Maintained for compatibility

#### IntelliJ IDEA
- Vim keybindings through IdeaVim plugin
- Consistent with other vim configurations

#### Obsidian
- Extensive vim configuration for note-taking
- Optimized for markdown editing

### Terminal and File Management

#### Tmux
- True color support
- Vi key bindings
- Custom status bar

#### LF File Manager
- Preview scripts for various file types
- FZF integration for file search

### macOS Integration

#### Karabiner Elements
- Custom keyboard modifications
- Optimized for development workflow

## Installation Process

The installation is fully automated through Dotbot:

1. **Symbolic Links**: Creates links from repository to appropriate locations
2. **Directory Creation**: Automatically creates necessary directories
3. **Submodule Updates**: Initializes and updates git submodules
4. **Clean Setup**: Removes broken symlinks before installation

## Development Environment

This setup is optimized for:

- **Modern CLI Workflow**: ripgrep, fzf, bat, delta integration
- **Multi-Editor Development**: Consistent vim experience across editors
- **Git-Centric Development**: Enhanced diff viewing and lazy git integration
- **macOS Development**: Native tool integration and keyboard optimization
- **Container Development**: Aliases for proxied and containerized tools

## Key Integration Points

- **Search Experience**: FZF + Ripgrep + Bat for unified search and preview
- **Consistent Prompts**: Starship provides uniform prompt across terminals
- **Enhanced Git**: Delta improves diff viewing in git and lazygit
- **Vim Everywhere**: Consistent vim keybindings across all editors
- **Quick Access**: Shell aliases for rapid tool access

## Customization

To customize for your environment:

1. **Edit Configuration Files**: Modify files in the repository root
2. **Update Mappings**: Edit `install.conf.yaml` for new file locations
3. **Reinstall**: Run `./install` to apply changes
4. **Personal Settings**: Create conditional includes in git config

## Requirements

- **macOS**: Primary support (some configurations are macOS-specific)
- **Zsh**: Required for shell configuration
- **Git**: Required for installation and submodules
- **Python**: Required for Dotbot

## Contributing

This is a personal dotfiles repository, but feel free to:

- Fork and adapt for your own use
- Submit issues for bugs or improvements
- Share interesting configurations or optimizations

## License

MIT License - feel free to use and modify as needed.

---

*This dotfiles setup provides a comprehensive development environment with modern tools and consistent configurations across multiple editors and platforms.*