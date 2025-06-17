export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git extract zsh-syntax-highlighting history-substring-search zsh-autosuggestions z)

source $ZSH/oh-my-zsh.sh

# alias
alias proxy='export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890'
alias unproxy='unset http_proxy https_proxy all_proxy'
alias rm="trash -F"
# 忽略大小写和正则
alias -g G='| rg -i -F'
alias -g L='| less'
alias vim='nvim'
alias v='nvim'
alias vi='nvim'
# 支持 OWNER/REPO 和 https://github.com/cli/cli
alias gcll='gh repo clone'
alias bs='brew services'
alias k2='kubectl -s="https://192.168.2.201:6443" --insecure-skip-tls-verify=true  --token="eyJhbGciOiJSUzI1NiIsImtpZCI6IlI1b2FtclFPVjRaMHFLckgwUFJiRGtWWHpOdk12S1h5cTAzSDE4WHVvTjAifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZXYiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoiZGV2LXRlc3QtdG9rZW4tbmhtc3QiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGV2LXRlc3QiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJlMjFlOTJiNC1mN2M5LTQ0NmYtOWRjMi1jYjE5MTYyMTNkNDEiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGV2OmRldi10ZXN0In0.kjy40FmzFfKKcLbYhLnXy_hGdwMd6-4ImB4-9qfk9P0SfRb9z_jyPg2OAhmkZ_a6xdsJmrLXur22PKp1868fZzEElVpCYpW-zhZYl2DNPbOR-ckz7Jtna-ZerFovIKB4tVrdbUil3vjG1EML3zqgy4fWeNeHzkVgBjdMAKj9y4YpIqKiSQjmFWZj4oHL49kqygzD-1uO1f_o9ja0O4UwgUfppv05UFT_htucsVS0-wt_8QGG5euUnglNPN9g15r6caIyMKh4tdiwGLexJw4U4haogXZ2CCwCRGC6fVGESsP2fkSm0hJFfw1x_N_61qv3_kLIwRA-6nbJ8aFAZLFYBQ"'
alias kp='k2 get po -n dev | rg -i'
alias kl='_kl(){podName=$(kp ^$1 | awk '\''{print $1}'\'');k2 logs -n dev -f $podName};_kl'
alias ukl='_ukl(){podName=$(kubectl get po -n uat G ^$1 | awk '\''{print $1}'\'');kubectl logs -n uat -f $podName};_ukl'
alias ukp='kubectl get po -n uat | rg -i'

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

# fzf setting
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# 使用 rg 进行搜索, 而不是find搜索, 需要安装ripgrep, 且忽略.git 目录
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*"'
# 使用bat进行预览, bat会语法高亮, 支持git高亮,需要安装bat
# 设置bat的主题
export BAT_THEME="Dracula"
export FZF_DEFAULT_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"

# 定义 rg + fzf 全文搜索函数
rgfzf() {
  local RG_PREFIX="rg --column --files-with-matches --smart-case --color=always --fixed-strings"
  local INITIAL_QUERY=""
  local CHOICE=$(fzf --bind "change:reload:$RG_PREFIX {q} || true" \
    --sort \
    --multi \
    --preview '[[ ! -z {} ]] && rg --ignore-case --pretty --context 5 --fixed-strings {q} {}' \
    --ansi --phony --query "$INITIAL_QUERY" \
    --prompt "字面量搜索> " \
    --header "F2:切换到正则模式" \
    --bind "f2:change-prompt(正则搜索> )+reload(rg --column --files-with-matches --smart-case --color=always {q} || true)+change-preview([[ ! -z {} ]] && rg --ignore-case --pretty --context 5 {q} {})")

  [ -n "$CHOICE" ] && "$EDITOR" "$CHOICE"
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
