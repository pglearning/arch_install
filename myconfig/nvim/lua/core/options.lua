vim.opt.number = true                   -- 显示行号
vim.opt.relativenumber = true           -- 相对行号, 显示当前光标位置行号, 其他为相对光标位置的行号距离
vim.opt.numberwidth = 4                 -- 行号占用的宽度, 超出时会自动扩展 (default) 4

vim.opt.history = 10000                 -- 命令保存的历史上限
vim.opt.tabstop = 4                     -- Tab 显示宽度
vim.opt.shiftwidth = 4                  -- 自动缩进宽度
vim.opt.expandtab = true                -- 将 Tab 转换为空格
vim.opt.softtabstop = 4                 -- Backspace 删除 4 个空格 (兼容 tab 字符)
vim.opt.backspace = "indent,eol,start"  -- 允许跨行/缩进删除, (default "indent,eol,start")
vim.opt.wrap = false                    -- 自动换行
vim.opt.linebreak = true                -- 自动换行会在单词边界处换, 而不是拆开字符, 只有开启wrap才有用, 中文要单独设置breakat (default) off
vim.opt.cursorcolumn = false            -- 显示列高亮
vim.opt.cursorline = true               -- 显示行高亮
vim.opt.cursorlineopt = "both"          -- 高亮行的属性, 可以是(default "both"), "line", "screenline", "number"
vim.opt.scrolloff = 10                  -- 光标距离顶部和底部 n 行固定
vim.opt.list = true                     -- 显示不可见字符, 比如默认为 Tab='>' 行尾空格='-' 不换行空格='+' (default) off
vim.opt.listchars = "tab:>-,trail:-,nbsp:+,lead:·,conceal:*"  -- 显示不可见字符的格式, (default)"tab:> ,trail:-,nbsp:+"
-- vim.opt.listchars = {                -- 同上, 另一种写法
--   tab = ">─",      -- Tab 显示为 ">──"
--   trail = "·",     -- 行尾空格显示为点
--   eol = "$",       -- 行尾显示美元符
--   nbsp = "␣",      -- 不换行空格
-- }
vim.opt.matchpairs = "(:),{:},[:],<:>"  -- '%'跳转位置的配对模式, (default)"(:),{:},[:]"
vim.opt.showmatch = true                -- 高亮匹配括号的时间
vim.opt.matchtime = 5                   -- 当showmatch开启时, 控制匹配括号高亮的显示时间 (default) 5 = 0.5s
vim.opt.more = false                    -- 输出的消息过长时是否暂停并显示<more>以回车继续输出 (default) on
vim.opt.mouse = "a"                     -- 启用鼠标支持, (default)"nvi" 对应Normal, Visual, Insert Mode等 "a"为所有模式启用鼠标
vim.opt.mousescroll = "ver:3,hor:6"     -- 鼠标滚动时的行数(默认3)和列数(默认6) (default) "ver:3,hor:6"

vim.opt.autochdir = false               -- 自动修改当前工作目录为打开文件的目录
vim.opt.autoread = true                 -- 如果当前文件被外部程序修改, 会重新加载该文件
vim.opt.autowrite = false               -- 自动保存
vim.opt.backup = false                  -- 在修改文件时自动创建备份文件, 直到文件被成功保存(写入)
-- vim.opt.backupcopy = "auto"             -- 当backup为真时可以使用这个, 决定在修改文件时备份文件的行为, (default "auto")
-- vim.opt.backupdir = ".,$XDG_STATE_HOME/nvim/backup//"  -- backup文件创建的位置, (default ".,$XDG_STATE_HOME/nvim/backup//")
vim.opt.undofile = true                 -- 保存撤回历史记录到文件, 重新打开文件时可以撤回上次修改
vim.opt.undolevels = 1000               -- 可以保存的撤回记录上限
vim.opt.confirm = true                  -- 保存文件需要确认
vim.opt.fileformat = "unix"             -- 设置当前文件的换行格式(default Windows: "dos" = "\r\n" = <CR><NL>, Unix: "unix" = "\n" = <NL>)
vim.opt.fsync = true                    -- 每次保存时调用fsync写入物理硬件中, 而不是留在内存缓存。(default on)

vim.opt.hlsearch = true                 -- 高亮所有匹配搜索的内容
vim.opt.incsearch = true                -- 实时预览搜索的结果
vim.opt.iminsert = 0                    -- 决定插入模式的输入模式, 设置为2使用外部输入法IM。(default 0)
vim.opt.imsearch = 0                    -- 决定搜索模式的输入模式, (default -1 与iminsert相同行为) 0为lmap和IM关闭, 1为lmap开IM关
vim.opt.inccommand = "split"            -- 使用替换命令时的显示效果, 如: ":%s/foo/bar/g"在(default "nosplit")下会在缓冲区实时预览, 而"split"会在下方小窗口显示屏幕外的预览, ""不显示
vim.opt.autoindent = true               -- 自动缩进, 继承上一行缩进
vim.opt.smartindent = true              -- 智能缩进

vim.opt.clipboard = "unnamedplus"       -- 系统剪切板支持(unnamedplus: *寄存器)(unnamed: +寄存器)
-- vim 的 d 键附带剪切会把系统剪切板搞乱?

vim.opt.ignorecase = true               -- 搜索忽略大小写
vim.opt.smartcase = true                -- 智能大小写搜索

-- Window
vim.opt.splitbelow = true               -- 默认新窗口为下边
vim.opt.splitright = true               -- 默认新窗口为右边
vim.opt.equalalways = true              -- 分割的窗口尺寸永远相等
vim.opt.eadirection = "both"            -- 设置equalalways的行为, 让垂直或水平的尺寸不受影响,(default "both"), "ver", "hor"
vim.opt.laststatus = 2                  -- 显示窗口的状态线,  0: 不显示; 1: 至少2个窗口存在; (default)2: 一直显示; 3: 只显示最后一个窗口的
-- vim.opt.lines = 40                   -- 固定窗口行大小, 默认为终端窗口大小 或 24
-- vim.opt.columns= 120                 -- 固定窗口列大小, 默认为终端窗口大小 或 80

vim.opt.signcolumn = "yes"              -- 左侧多一列, 可以方便debug和插件提示
vim.opt.termguicolors = true            -- 启用真彩色, 支持外观主题
vim.opt.background = "dark"             -- 设置背景颜色, (default "dark"), "light"

vim.opt.icon = true                     -- 当nvim与终端交互时, 修改窗口标题文本title, 大部分现代终端已经不支持了。(default off)
vim.opt.iconstring = ""                 -- 手动设置窗口标题文本, 这个选项为空且icon为on时, 设置为当前文件名。支持%f相对路径文件名等, 详细查看文档

-- Reading docs: https://neovim.io/doc/user/options/#'iconstring' to 'quickfixtextfunc'
