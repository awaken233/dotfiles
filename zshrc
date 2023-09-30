export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git extract zsh-syntax-highlighting history-substring-search zsh-autosuggestions z kubectl)

source $ZSH/oh-my-zsh.sh

alias proxy='export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890'
alias unproxy='unset http_proxy https_proxy all_proxy'
alias rm="trash -F"
alias lg="lazygit"
alias -g G='| grep -i'
alias vim='nvim'
alias v='nvim'
alias vi='nvim'

___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"; if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "${___MY_VMOPTIONS_SHELL_FILE}"; fi

# history-substring-search setting
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
# tmux up/down search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# tmux 真彩色配置
export TERM="screen-256color"
# 设置zsh的prompt, 需要安装starship
eval "$(starship init zsh)"

# lf configuration
# 设置lf默认的编辑器
export VISUAL=nvim
export PAGER=bat

# fzf setting
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# 使用 rg 进行搜索, 而不是find命令进行搜索, 需要安装ripgrep
export FZF_DEFAULT_COMMAND='rg --files --hidden'
# 使用bat进行预览, bat会语法高亮, 支持git高亮,需要安装bat
# 设置bat的主题
export BAT_THEME="Dracula"
export FZF_DEFAULT_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"

