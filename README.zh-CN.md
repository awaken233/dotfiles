# Dotfiles

> **其他语言:** [English](README.md)

一个使用 **Dotbot** 进行自动化配置管理的综合性个人 dotfiles 仓库，支持多种开发环境。

## 特性

- 🚀 **自动化安装**: 使用 Dotbot 一键安装
- 🔧 **现代化 CLI 工具**: 集成 ripgrep、fzf、bat、delta 和 starship
- 🎨 **多编辑器支持**: 支持 Neovim (LazyVim)、Vim、IntelliJ IDEA 和 Obsidian
- 🐚 **增强的 Shell**: Zsh 配合 Oh-My-Zsh，语法高亮和自定义别名
- 📁 **文件管理**: LF 文件管理器配备预览支持
- 🔀 **Git 工作流**: LazyGit 集成和增强的差异查看
- ⌨️ **键盘优化**: 针对 macOS 的 Karabiner Elements 配置
- 🖥️ **终端多路复用**: 支持 vi 键绑定和真彩色的 Tmux

## 快速开始

```bash
# 克隆仓库
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 安装所有配置
./install
```

## 项目结构

```
.
├── install                 # 主安装脚本
├── install.conf.yaml      # Dotbot 配置文件
├── CLAUDE.md              # AI 助手指导文档
├── dotbot/                # Dotbot 子模块
│
├── Shell 和终端
├── zshrc                  # Zsh 配置文件，包含 Oh-My-Zsh
├── tmuxconf              # Tmux 配置文件
│
├── Git 和版本控制
├── gitconfig             # Git 配置
├── gitignore_global      # 全局 gitignore
├── lazygit_config        # LazyGit 配置
│
├── 编辑器
├── lazyvim/              # Neovim (LazyVim) 配置
├── vimrc                 # 传统 Vim 配置
├── ideavimrc             # IntelliJ IDEA vim 插件
├── obsidianvimrc         # Obsidian vim 插件
│
├── 工具和实用程序
├── lf/                   # LF 文件管理器配置
└── karabiner/            # Karabiner Elements (macOS)
```

## 配置详情

### Shell 环境 (zshrc)

- **框架**: Oh-My-Zsh 配合自定义插件
- **插件**: syntax-highlighting、autosuggestions、history-substring-search
- **提示符**: Starship 集成的现代提示符
- **别名**: 丰富的开发别名，支持 proxy、git、kubectl、maven
- **函数**: 自定义函数如 `rgfzf()`、`lg()`、`project_lazygit()`
- **FZF 集成**: 配合 bat 实现文件预览功能

### Git 工作流

- **分页器**: Delta 提供增强的差异查看
- **配置**: 支持工作/个人设置的条件包含
- **LazyGit**: 自定义 IDE 集成命令
- **全局忽略**: 处理 IDE 文件和构建产物

### 编辑器配置

#### Neovim (LazyVim)
- 完整的 LazyVim 设置，包含自定义插件
- 位于 `lazyvim/` 目录
- 现代化的 Lua 配置

#### 传统 Vim
- 使用 vim-plug 的经典 vim 配置
- 保持兼容性

#### IntelliJ IDEA
- 通过 IdeaVim 插件实现 vim 键绑定
- 与其他 vim 配置保持一致

#### Obsidian
- 为笔记记录优化的扩展 vim 配置
- 专门为 markdown 编辑优化

### 终端和文件管理

#### Tmux
- 真彩色支持
- Vi 键绑定
- 自定义状态栏

#### LF 文件管理器
- 支持各种文件类型的预览脚本
- FZF 集成实现文件搜索

### macOS 集成

#### Karabiner Elements
- 自定义键盘修改
- 为开发工作流程优化

## 安装过程

安装过程通过 Dotbot 完全自动化：

1. **符号链接**: 从仓库到适当位置创建链接
2. **目录创建**: 自动创建必要的目录
3. **子模块更新**: 初始化和更新 git 子模块
4. **清理设置**: 安装前移除损坏的符号链接

## 开发环境

此设置针对以下场景优化：

- **现代 CLI 工作流**: ripgrep、fzf、bat、delta 集成
- **多编辑器开发**: 跨编辑器的一致 vim 体验
- **以 Git 为中心的开发**: 增强的差异查看和 lazy git 集成
- **macOS 开发**: 原生工具集成和键盘优化
- **容器开发**: 代理和容器化工具的别名

## 关键集成点

- **搜索体验**: FZF + Ripgrep + Bat 实现统一的搜索和预览
- **一致的提示符**: Starship 在所有终端中提供统一的提示符
- **增强的 Git**: Delta 改善 git 和 lazygit 中的差异查看
- **无处不在的 Vim**: 所有编辑器中一致的 vim 键绑定
- **快速访问**: Shell 别名实现快速工具访问

## 自定义

根据你的环境进行自定义：

1. **编辑配置文件**: 修改仓库根目录中的文件
2. **更新映射**: 编辑 `install.conf.yaml` 设置新的文件位置
3. **重新安装**: 运行 `./install` 应用更改
4. **个人设置**: 在 git 配置中创建条件包含

## 要求

- **macOS**: 主要支持（部分配置专门针对 macOS）
- **Zsh**: shell 配置必需
- **Git**: 安装和子模块必需
- **Python**: Dotbot 必需

## 贡献

这是一个个人的 dotfiles 仓库，但欢迎：

- Fork 并为自己的使用进行调整
- 提交问题报告错误或改进建议
- 分享有趣的配置或优化

## 许可证

MIT 许可证 - 请自由使用和修改。

---

*这个 dotfiles 设置提供了一个全面的开发环境，具有现代化工具和跨多个编辑器和平台的一致配置。*