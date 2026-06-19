" 自动代码说明: 切换至普通模式，将光标移动到这些文字中的任意一行，然后敲击 za 进行代码折叠。
"       Vim 会折叠从包含 {{{ 的行到包含 }}} 的行之间的所有行，再敲击 za 会展开所有这些行
"   详见折叠命令：
"       za         打开或关闭当前折叠(open a closed fold, close an open fold)
"       zc         折叠(close a fold)
"       zo         展开折叠(close a fold)
"       zM         关闭所有折叠(set 'foldlevel' to zero)
"       zR         打开所有折叠(set 'foldlevel' to zero)
" 自动代码折叠函数 (Vimscript File Settings) {{{
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END
" }}}

"""""""""""""""""""""""""""""
" View
"""""""""""""""""""""""""""""
set number                      " 显示行号
set relativenumber              " 行号以相对当前行的方式显示，方便跳转
"set showtabline=2		         " 显示顶部标签栏，为 0 时隐藏标签栏, 1 会按需显示, 2 会永久显示
"set tabpagemax=10               " 设置最大标签页上限为 10
"set cursorline                  " 显示当前选中 行下划线, 开启真彩色后会导致这一行添加白色(默认)背景, 看不清
"set cursorcolumn                " 显示当前选中 列高亮
"set shortmess=atI               " 不显示援助乌干达儿童提示
set scrolloff=5                 " 编辑时上下的距离, 光标距离顶部和底部 5 行
"set ruler                       " 显示光标当前位置
set showmatch                   " 高亮显示匹配的括号
"set matchtime=1                 " 匹配括号高亮的时间（单位是十分之一秒） 
set showmode                    " 显示当前所处的模式
"set showcmd                     " 显示输入的命令
"set completeopt=longest,menu    " 打开预览窗口会导致下拉菜单抖动，一般都去掉预览窗口的显示

set equalalways                 " 分割窗口时保持相等的宽/高
set splitright                  " 竖直 split 时，在右边开启
set splitbelow                  " 水平 split 时，在下边开启

"set signcolumn=yes              " 左侧多一列，可以方便debug和插件提示
set title                       " 文件名显示在窗口标题栏中
set laststatus=2		        " 命令行为两行, 1-2
set cmdheight=2			        " 总是显示状态行
set background=dark             " 主题, 影响代码高亮颜色: light dark
set termguicolors                " 启用真彩色，支持外观主题

"""""""""""""""""""""""""""""
" Main Options
"""""""""""""""""""""""""""""
filetype on                     " 检测文件类型
filetype plugin on              " 设置多个 filetype 选项: 载入文件类型插件; filetype plugin indent on 为特定文件类型载入相关缩进文件
"syntax enable                   " 启用语法高亮度
syntax on                       " 开启语法高亮
"set spell                               " 拼写检查, vim默认安装了英语字典

"set magic                       " 设置魔术, 正则表达式搜索
set hlsearch                    " 高亮搜索的字符串
set incsearch                   " 即时搜索

set wrap                        " 设置代码自动换行
set tabstop=4                   " Tab 显示多少个空格，默认 8
set shiftwidth=4                " 每一级缩进是多少个空格
set expandtab                   " 将 Tab 转换为空格
"set noexpandtab                 " 不允许用空格代替制表符
set autoindent                  " 自动缩进，把上一行的对齐格式应用到下一行
"set smartindent                 " 开启智能缩进
"set cindent                     " 设置 C 样式的缩进格式
"set softtabstop=4               " 统一缩进为 4

set ignorecase                  " 搜索时忽略大小写
set smartcase                   " 智能大小写敏感，只要有一个字母大写，就大小写敏感，否则不敏感
set history=1000                " 记录 1000 条历史命令

"set foldmethod=indent           " 基于缩进进行代码折叠，fdm 是 foldmethod 的缩写
"set nofoldenable                " 启动 Vim 时关闭折叠
"set selection=exclusive         " 指定在选择文本时光标所在位置也属于被选中的范围

"set noeb                        " 去掉输入错误的提示声音
set mouse=a                     " 启用鼠标
set clipboard=unnamedplus       " 共享剪贴板 Wayland 用 unnamedplus(对应 "+ 寄存器) X11 用 unnamed(对应 "* 寄存器)
"set autoread                    " 设置当文件被改动时自动载入
"set autowrite                   " 自动保存
"set selectmode=mouse,key        " 使鼠标和键盘都可以控制光标选择文本
"set backspace=2                 " 设置退格键可用，正常处理 indent, eol, start
"set whichwrap+=<,>,h,l          " 允许 Backspace 和光标键跨越行边界

"set confirm                     " 在处理未保存或只读文件的时候，弹出确认
"set nobackup                    " 禁止备份
"set noswapfile                  " 禁止生成临时文件
"set noundofile                  " 不生成 undo 文件
"set report=0                    " 通过使用 :commands 命令，告诉我们文件的哪一行被改变过
"set viminfo+=!                  " 保存全局变量
"set iskeyword+=_,$,@,%,#,-      " 带有如下符号的单词不要被换行分割
"set autochdir                   " 自动切换工作目录为当前文件所在的目录，修改或者添加文件的时候，特别有用

"""""""""""""""""""""""""""""
" 编码方式及菜单设置
"""""""""""""""""""""""""""""
"set encoding=utf-8              " Vim 内部 buffer (缓冲区)、菜单文本等使用的编码方式，以下统一使用 UTF-8, 减少编码问题
"set termencoding=utf-8          " Vim 所工作的终端的字符编码方式
"set fileformats=unix,dos,mac    " Vim 自动识别文件格式,缩写:se ff;回车键编码不同:dos 是回车加换行,unix 只有换行符,mac 只有回车符
"set fileformat=unix             " 设置以 UNIX 的格式保存文件，尽量通用
"set fileencoding=utf-8          " 当前编辑文件的字符编码方式，保存文件也使用这种编码方式
" Vim 启动时逐一按顺序使用第一个匹配到的编码方式打开文件；chinese 是别名，在 Unix 里表示 GB2312，在 Windows 里表示 cp936；cp936 是 GBK 的别名，是 GB2312 的超集，可以支持繁体汉字，也避免删除半个汉字
"set fileencodings=ucs-bom,utf-8,default
"set formatoptions+=m            " 表示自动排版完成的方式。m 表示在任何值高于 255 的多字节字符上分行
"set formatoptions+=B            " B 表示在连接行时，不要在两个多字节字符之间插入空格

"""""""""""""""""""""""""""""
" Keymap
"""""""""""""""""""""""""""""
let mapleader=" "                       " 设置leader键为空格

nnoremap <leader>cc :close<CR>              " 关闭聚焦窗口
nnoremap <leader>sv <C-w>v                  " 新增水平窗口
nnoremap <leader>sh <C-w>s                  " 新增垂直窗口
nnoremap <leader>nh :nohl<CR>               " 取消高亮显示

nmap <C-a> ggVG			                " 选择全部

vmap J :m '>+1<CR>gv=gv                 " 选中多行后按 shift + j 向上移动代码块
vmap K :m '<-2<CR>gv=gv                 " 选中多行后按 shift + K 向下移动代码块
