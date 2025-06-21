#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#PS1='[\u@\h \W]\$ '

#############################
### VISUAL
#############################

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias dmesg='dmesg --color'

if [[ -x "$(command -v nvim)" ]]; then
    alias vi='nvim'
    alias vim='nvim'
    alias svi='sudo nvim'
    alias vis='nvim "+set si"'
    export EDITOR=nvim visudo
    export VISUAL=nvim visudo
    export SUDO_EDITOR=nvim
    export FCEDIT=nvim
elif [[ -x "$(command -v vim)" ]]; then
    alias vi='vim'
    alias svi='sudo vim'
    alias vis='vim "+set si"'
    export EDITOR=vim visudo
    export VISUAL=vim visudo
    export SUDO_EDITOR=vim
    export FCEDIT=vim
fi

# LS
export LS_COLORS="${LS_COLORS}ow=01;37;42:"
alias ls='ls -Fh --color=always'
alias ll='ls -Fls'
alias la='ls -FAh'
alias l.='ll -d .*'

# 显示cd 前的路径
alias pwd-='echo ${OLDPWD}'

# 返回home 文件夹
alias home='\cd ~'

# 允许少一个空格也能用
alias cd..='\cd ..'

# 允许少一个空格也能用，跳转到cd 前的路径
alias cd-='cd -'

# Go back directories dot style
alias ..='\cd ..'
alias ...='\cd ../..'
alias ....='\cd ../../..'
alias .....='\cd ../../../..'

# Go back directories dot dot number style
alias ..2='..; ..'
alias ..3='..2; ..'
alias ..4='..3; ..'
alias ..5='..4; ..'

# find 从当前文件夹开始找，从根目录开始要管理员权限
alias f='find . -name'
alias ffile='find . -type f -iname'
alias fdir='find . -type d -iname'

# Count how many files in current directory
alias countfiles='find . -type f | wc -l'

# Check command is aliased, a file, or a built-in command
alias check="type -t"

# 复制文件时，覆盖文件提示
alias cp='cp -i'

# 移动文件时，目标已存在，提示确认
alias mv='mv -i'

# 链接文件或文件夹，移除目标前提示
alias ln='ln -i'

# 删除文件前提示
alias rm='rm -i --preserve-root'

# 删除文件夹和所有文件
alias rmd='\rm --recursive --force --verbose'

# 根据需要创建父文件夹
alias mkdir='mkdir -p'

# 不对/ 根目录做修改
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

alias df='df --human-readable --print-type --exclude-type=squashfs'
alias ds='df --human-readable --print-type --exclude-type=squashfs --exclude-type=tmpfs --exclude-type=devtmpfs'

# tar
alias mkbz2='tar -cvjf'
alias unbz2='tar -xvjf'
alias mkgz='tar -cvzf'
alias ungz='tar -xvzf'
alias mktar='tar -cvf'
alias untar='tar -xvf'

#############################
### DATE AND TIME
#############################

alias now='date +"%T"'

alias today='date +"%Y-%m-%d"'

alias stopwatch='date && echo "Press CTRL-D to stop" && time read'

#############################
### CPU, MEMORY, PROCESSES
#############################

# Display amount of free and used memory
alias free='free -h'

# When reporting a snapshot of the current processes:
# a = all users
# u = user-oriented format providing detailed information
# x = list the processes without a controlling terminal
# f = display a tree view of parent to child processes
alias ps='ps auxf'

# Show top ten processse
alias cpu='ps aux | sort -r -nk +4 | head | $PAGER'

# Show CPU information
alias cpuinfo='lscpu | $PAGER'

# Show the USB device tree
if [[ -x "$(command -v lsusb)" ]]; then
    alias pci='lsusb -t'
fi

# Show the PCI device tree
if [[ -x "$(command -v lspci)" ]]; then
    alias pci='lspci -tv'
fi

# Net
alias ipaddr='ip addr'