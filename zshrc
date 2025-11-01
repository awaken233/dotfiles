export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
  git
  extract
  zsh-syntax-highlighting
  history-substring-search
  zsh-autosuggestions
  z
  kubectl
)

source $ZSH/oh-my-zsh.sh

# alias
alias proxy='export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890'
alias unproxy='unset http_proxy https_proxy all_proxy'
alias rm="trash -F"
# 忽略大小写和正则
alias -g G='| rg -i -F'
alias -g L='| less'
alias -g F='| fzf'
alias -g C='| pbcopy'
alias vim='nvim'
alias v='nvim'
alias vi='nvim'
# 支持 OWNER/REPO 和 https://github.com/cli/cli
alias gcll='gh repo clone'
alias bs='brew services'

# 跳过测试
alias mi='mvn clean install -Dmaven.test.skip=true'
# 下载源码
alias ms='mvn dependency:resolve -Dclassifier=sources'

# history-substring-search setting
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
# tmux up/down search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
# zsh-autosuggestions 只接受一个单词
bindkey '^F' forward-word

# tmux 真彩色配置
export TERM="screen-256color"
# 设置zsh的prompt, 需要安装starship
eval "$(starship init zsh)"

# lf configuration
# 设置lf默认的编辑器
export VISUAL=nvim
export PAGER=bat
export EDITOR=/opt/homebrew/bin/nvim

# 设置bat的主题
export BAT_THEME="Dracula"

# fzf setting
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# 使用 rg 进行搜索, 而不是find搜索, 需要安装ripgrep, 且忽略.git 目录
# export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*"'
export FZF_DEFAULT_COMMAND='fd --type f'
# 使用bat进行预览, bat会语法高亮, 支持git高亮,需要安装bat
export FZF_DEFAULT_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"

# 定义 rg + fzf 全文搜索函数, enter 打开并跳转到目标行和列
rgfzf() {
  local RG_PREFIX="rg --line-number --column --smart-case --color=always --fixed-strings"
  local INITIAL_QUERY=""
  local CHOICE=$(fzf --bind "change:reload:$RG_PREFIX {q} || true" \
    --sort \
    --multi \
    --delimiter : \
    --preview 'bat --color=always --style=numbers --highlight-line {2} {1}' \
    --preview-window 'right,60%,+{2}+3/3,~3,border-left' \
    --ansi --phony --query "$INITIAL_QUERY" \
    --prompt "字面量搜索> " \
    --header "F2:切换到正则模式 | Enter:跳转到目标行" \
    --bind "f2:change-prompt(正则搜索> )+reload(rg --line-number --column --smart-case --color=always {q} || true)")

  if [ -n "$CHOICE" ]; then
    # 解析文件名、行号和列号 (格式: filename:line:column:content)
    local filename=$(echo "$CHOICE" | cut -d: -f1)
    local line_number=$(echo "$CHOICE" | cut -d: -f2)
    local column_number=$(echo "$CHOICE" | cut -d: -f3)
    
    # 使用 nvim 打开到指定行和列
    nvim "+call cursor(${line_number}, ${column_number})" "$filename"
  fi
}

# 将函数注册为 zsh 编辑器小部件
zle -N rgfzf
bindkey '^S' rgfzf


# 当使用 ctrl+r 切换了 repo, 退出 shell 将将当前目录切换到 repo 目录, 如果希望不切换目录, 可以按下 shift+Q
lg()
{
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir

    lazygit "$@"

    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
            cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
            rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
    fi
}

# 快速打开指定项目目录的 lazygit
project_lazygit() {
  local selected_dir=$(fd -t d -d 1 '' ~/IdeaProjects ~/Idea2 ~/PycharmProjects 2>/dev/null | fzf --prompt "选择项目目录> " --preview 'ls -la {}')
  
  if [[ -n "$selected_dir" ]]; then
    lazygit -p "$selected_dir"
  fi
}

# 将函数注册为 zsh 编辑器小部件
zle -N project_lazygit
bindkey '^G' project_lazygit

# 快速打开指定项目目录的 nvim
project_nvim() {
  local selected_dir=$(fd -t d -d 1 '' ~/IdeaProjects ~/Idea2 ~/PycharmProjects 2>/dev/null | fzf --prompt "选择项目目录> " --preview 'ls -la {}')
  
  if [[ -n "$selected_dir" ]]; then
    cd "$selected_dir" && nvim .
  fi
}

# 将函数注册为 zsh 编辑器小部件
zle -N project_nvim
bindkey '^V' project_nvim

# K8s 多集群管理
function switch-to-dev() {
    kubectx dev
    kubens dev
    echo "✅ 已切换到dev环境"
}

function switch-to-scilink() {
    kubectx scilink
    kubens scilink
    echo "✅ 已切换到scilink环境"
}

alias kdev='switch-to-dev'
alias ksci='switch-to-scilink'


# 使用 fzf 交互式搜索并选择一个 Pod
kfp() {
    # 不显示 fzf 预览框，按回车后复制名称到剪贴板并回显
    local selected_pod
    selected_pod=$(kubectl get pods --no-headers \
      | fzf --prompt="Select Pod> " --preview-window=hidden \
      | awk '{print $1}')

    if [[ -n "$selected_pod" ]]; then
        printf "%s" "$selected_pod" | pbcopy
        printf "%s\n" "$selected_pod"
    fi
}

# 使用 fzf 交互式搜索并选择一个 Pod，然后查看其日志
kfl() {
    # 执行 kfp 函数获取选中的 Pod 名称
    local selected_pod=$(kfp)
    # 检查是否选中了 Pod (即 kfp 没有返回空)
    if [[ -n $selected_pod ]]; then
        kubectl logs "$selected_pod" -f
    fi
}

# 获取指定 deployment 的镜像
kgdi() {
    if [ $# -eq 0 ]; then
        echo "Usage: kgdi <deployment-name>"
        return 1
    fi
    
    kubectl get deployment "$1" -o jsonpath='{.spec.template.spec.containers[*].image}'
    echo  # 添加换行
}