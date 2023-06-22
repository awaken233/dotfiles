" Configuration file for vim
set modelines=0		" CVE-2007-2438

" Normally we use vim-extensions. If you want true vi-compatibility
" remove change the following statements
set nocompatible	" Use Vim defaults instead of 100% vi compatibility
set backspace=2		" more powerful backspacing

" Don't write backup file if vim is being called by "crontab -e"
au BufWrite /private/tmp/crontab.* set nowritebackup nobackup
" Don't write backup file if vim is being called by "chpass"
au BufWrite /private/etc/pw.* set nowritebackup nobackup

let skip_defaults_vim=1
syntax on
set number
set clipboard=unnamed
set relativenumber	" 显示从当前行数的前后行数
set cursorline	" 高亮显示当前行
set showcmd	" 显示指令
set wildmenu	" 命令补全
set hlsearch	" 高亮显示搜索
set incsearch	" 动态高亮搜索"
set smartcase	" 智能大小写搜索
set ignorecase " 大小写不敏感查找 
set showmode
set laststatus=2
set  ruler
set sm!                                  " 高亮显示匹配括号
filetype plugin on " 智能文件类型检测


call plug#begin('~/.vim/plugged')
Plug 'gcmt/wildfire.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'vim-autoformat/vim-autoformat'
call plug#end()

"autoformat config
let g:python3_host_prog="/opt/homebrew/bin"
