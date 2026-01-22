export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# autoswitch_virtualenv 默认使用 Python
alias python='python3'
plugins=(
  git
  extract
  history-substring-search
	fzf-tab
  zsh-autosuggestions
  kubectl
	autoswitch_virtualenv
  zoxide
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# alias
alias proxy='export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890'
alias unproxy='unset http_proxy https_proxy all_proxy'
# trash 是 keg-only（因与 macOS 自带功能冲突，Homebrew 不自动链接到 /opt/homebrew/bin），需手动添加 PATH
export PATH="/opt/homebrew/opt/trash/bin:$PATH"
alias rm='trash'
# 忽略大小写和正则
alias -g G='| rg -i -F'
alias -g L='| less'
alias -g C='| pbcopy'
alias -g Y='-o yaml'
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
# 必须链接公司VPN下载普通jar, 所以单开一个别名, 这样不用链接VPN使用
alias mvn-ali='mvn -s ~/.m2/settings-ali.xml'


# history-substring-search / zsh-autosuggestions 的按键绑定统一放到下方 “ZLE 自定义按键绑定” 区域

# tmux 真彩色配置
# export TERM="screen-256color"
# 设置zsh的prompt, 需要安装starship
eval "$(starship init zsh)"

# lf configuration
# 设置lf默认的编辑器
export VISUAL=nvim
export PAGER=bat
export EDITOR=/opt/homebrew/bin/nvim

# 设置bat的主题，根据系统外观自动切换
export BAT_THEME_LIGHT="GitHub"
export BAT_THEME_DARK="Monokai Extended"

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


# 当使用 ctrl+r 切换了 repo, 退出 shell 将将当前目录切换到 repo 目录, 如果希望不切换目录, 可以按下 shift+Q
lg()
{
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir

    lazygit "$@"

    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
            cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
            command rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
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

# 快速打开指定项目目录的 nvim
project_nvim() {
  local selected_dir=$(fd -t d -d 1 '' ~/IdeaProjects ~/Idea2 ~/PycharmProjects 2>/dev/null | fzf --prompt "选择项目目录> " --preview 'ls -la {}')
  
  if [[ -n "$selected_dir" ]]; then
    cd "$selected_dir" && nvim .
  fi
}

# 将函数注册为 zsh 编辑器小部件
zle -N project_nvim

# zoxide：将 zi 注册为 zsh 编辑器小部件（交互式跳转）
zi_widget() {
  if (( $+functions[zi] )); then
    # 基于 zoxide 默认配置，替换 --exact 为 --no-exact，并添加智能匹配选项
    # 核心改动: --no-exact (启用模糊匹配) + -i (忽略大小写) + --algo=v2 (智能权重)
    _ZO_FZF_OPTS=" \
      --no-exact \
      -i \
      --algo=v2 \
      --no-sort \
      --bind=ctrl-z:ignore,btab:up,tab:down \
      --cycle \
      --keep-right \
      --border=sharp \
      --height=45% \
      --info=inline \
      --layout=reverse \
      --tabstop=1 \
      --exit-0 \
    " zi
    zle reset-prompt
  else
    zle -M "zi: function not found (is zoxide loaded?)"
    return 1
  fi
}

zle -N zi_widget

# ZLE 自定义按键绑定（集中放这里便于查占用/改键）
# - Ctrl+P/Ctrl+N：history-substring-search-up/down（覆盖默认的上一条/下一条历史）
# - ↑/↓：history-substring-search-up/down（用于 tmux 下上/下箭头也能搜索）
# - Ctrl+F：forward-word（覆盖默认的 forward-char；用于 zsh-autosuggestions 只接受一个单词）
#          使用 whitespace word style，只以空格为分隔符（例如 /、- 等符号不再是分隔符）
# - Ctrl+S：rgfzf（默认常见为 history-incremental-search-forward；且可能被终端当作 XON/XOFF）
# - Ctrl+G：project_lazygit（覆盖默认的 send-break/中断类行为）
# - Ctrl+V：project_nvim（覆盖默认的 quoted-insert）
# - Ctrl+Q：zi_widget（覆盖默认的 push-line）

bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
# 设置 forward-word 只以空格为分隔符（不再把 / - . 等符号当作单词边界）
# 记录：zsh 默认（不加载任何 rc）使用 word style=normal，且 WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>'（包含 /）
autoload -U select-word-style
select-word-style whitespace

bindkey '^F' forward-word
bindkey '^S' rgfzf
bindkey '^G' project_lazygit
bindkey '^V' project_nvim
bindkey '^Q' zi_widget

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

# lnav 实现的 tail：-t 将 stdin 视为日志内容，-q 静默模式，-c 执行命令跳转到末尾
ltail() {
  command lnav -t -q -c ':goto 100%' "$@"
}

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
        kubectl logs "$selected_pod" -f | ltail
    fi
}

# 使用 fzf 交互式选择一个 Deployment，然后持续追踪其日志（Pod 重启不中断）
kfd() {
    local selected_deploy

    selected_deploy=$(
        kubectl get deploy --no-headers 2>/dev/null \
          | fzf --prompt="Select Deploy> " --preview-window=hidden \
          | awk 'NF{print $1; exit}'
    )

    if [[ -z "$selected_deploy" ]]; then
        return 0
    fi

    command lnav -q -c ':goto 100%' -e "stern --output raw --color never deployment/${selected_deploy:q}"
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

# awk 提取列函数（跳过表头）
# 使用示例:
#   kubectl get pods | col 3          # 提取第3列
#   cat data.txt | col 2              # 提取第2列
#   col 1                             # 默认提取第1列
col() {
    local col_num=${1:-1}
    awk -v col=$col_num 'NR>1 {print $col}'
}

# 常用列的快捷别名
# 使用示例:
#   kubectl get pods | col2           # 提取第2列
#   kubectl get pods | col1           # 提取第1列
#   cat file.txt | col5               # 提取第5列
alias col1='col 1'
alias col2='col 2'
alias col3='col 3'
alias col4='col 4'
alias col5='col 5'
alias col6='col 6'
alias col7='col 7'
alias col8='col 8'
alias col9='col 9'
alias col10='col 10'


[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# FZF tab的配置
# 让 git checkout 的分支补全不排序（保持 git 默认顺序）
zstyle ':completion:*:git-checkout:*' sort false

# 显示 descriptions，并启用分组支持（别在这里放颜色转义）
zstyle ':completion:*:descriptions' format '[%d]'

# 使用 LS_COLORS 对文件/目录上色（需要你自己设置好 LS_COLORS）
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=32:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# 不让 zsh 自己弹出菜单，让 fzf-tab 接管
zstyle ':completion:*' menu no

# cd 补全目录时右侧预览内容（用 eza，没装可以换成 ls）
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1G $realpath'

zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
  'case "$group" in
  "modified file") git diff --color=always $word ;;
  "recent commit object name") git show --color=always $word ;;
  *) git log --color=always $word ;;
  esac'


# 自定义 fzf 参数（颜色、按 Tab 接受等）
zstyle ':fzf-tab:*' fzf-flags --bind=tab:accept

# 若你想继承 FZF_DEFAULT_OPTS（默认是不会继承的） 我默认预览的命令是 bat, 常见预览界面都会报错
zstyle ':fzf-tab:*' use-fzf-default-opts no

# fzf-tab 专用选项（不带预览，因为预览要按命令单独配置）
zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border --bind=tab:accept

# 改切换 group 的快捷键（比 F1/F2 顺手）
zstyle ':fzf-tab:*' switch-group '<' '>'


# Added by Windsurf
export PATH="/Users/ve/.codeium/windsurf/bin:$PATH"
# Added by CodeBuddy CN
export PATH="/Users/ve/.codebuddy/bin:$PATH"

# yazi 文件管理器
function f() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}
