export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git extract zsh-syntax-highlighting history-substring-search zsh-autosuggestions z)

source $ZSH/oh-my-zsh.sh

# alias
alias proxy='export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890'
alias unproxy='unset http_proxy https_proxy all_proxy'
alias rm="trash -F"
alias lg="lazygit"
alias -g G='| rg -i'
alias -g L='| less'
alias vim='nvim'
alias v='nvim'
alias vi='nvim'
alias bs='brew services'
alias k2='kubectl -s="https://192.168.2.200:6443" --insecure-skip-tls-verify=true  --token="eyJhbGciOiJSUzI1NiIsImtpZCI6IlI1b2FtclFPVjRaMHFLckgwUFJiRGtWWHpOdk12S1h5cTAzSDE4WHVvTjAifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZXYiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoiZGV2LXRlc3QtdG9rZW4tbmhtc3QiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGV2LXRlc3QiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJlMjFlOTJiNC1mN2M5LTQ0NmYtOWRjMi1jYjE5MTYyMTNkNDEiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGV2OmRldi10ZXN0In0.kjy40FmzFfKKcLbYhLnXy_hGdwMd6-4ImB4-9qfk9P0SfRb9z_jyPg2OAhmkZ_a6xdsJmrLXur22PKp1868fZzEElVpCYpW-zhZYl2DNPbOR-ckz7Jtna-ZerFovIKB4tVrdbUil3vjG1EML3zqgy4fWeNeHzkVgBjdMAKj9y4YpIqKiSQjmFWZj4oHL49kqygzD-1uO1f_o9ja0O4UwgUfppv05UFT_htucsVS0-wt_8QGG5euUnglNPN9g15r6caIyMKh4tdiwGLexJw4U4haogXZ2CCwCRGC6fVGESsP2fkSm0hJFfw1x_N_61qv3_kLIwRA-6nbJ8aFAZLFYBQ"'
alias kp='k2 get po -n dev | rg -i'
alias kl='_kl(){podName=$(kp ^$1 | awk '\''{print $1}'\'');k2 logs -n dev -f $podName};_kl'
alias ukl='_ukl(){podName=$(kubectl get po -n uat G ^$1 | awk '\''{print $1}'\'');kubectl logs -n uat -f --tail=2000 $podName};_ukl'

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

