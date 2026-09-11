vim.opt.number = true                   -- 显示行号
vim.opt.relativenumber = false          -- 相对行号, 显示当前光标位置行号, 其他为相对光标位置的行号距离
vim.opt.numberwidth = 4                 -- 行号占用的宽度, 超出时会自动扩展 (default) 4

vim.opt.path = vim.opt.path + {         -- 添加当前工作路径
    "./;",
}
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
vim.opt.scrolloff = 3                   -- 光标距离顶部和底部 n 行固定
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

-- 以下都是 nvim 的默认值, 显式写出来是为了明确"项目目录里不会产生 .swp/.un~ 等垃圾文件"
vim.opt.directory = vim.fn.stdpath("state") .. "/swap//"    -- 交换文件(.swp)位置
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo//"      -- 撤销历史(.un~)位置
vim.opt.backupdir = vim.fn.stdpath("state") .. "/backup//"  -- 备份文件位置
vim.opt.shada = "!,'100,<50,s10,h,r/tmp/,r/private/"        -- 不把 /tmp、/private 下的文件记进 :oldfiles
vim.opt.exrc = false                    -- 不自动加载项目里的 .nvim.lua (安全, (default) off)
-- 这几个目录不存在时 nvim 不会自动创建, 会导致撤销历史静默失效, 所以手动建一下
for _, dir in ipairs({ vim.opt.directory:get()[1], vim.opt.undodir:get()[1], vim.opt.backupdir:get()[1] }) do
    vim.fn.mkdir(dir, "p")
end

vim.opt.confirm = false                 -- 保存文件需要确认

-- auto-session 会按这个设置保存/恢复会话; 不设的话它会告警, 而且恢复后 filetype/高亮会错乱
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.opt.fileformat = "unix"             -- 设置当前文件的换行格式(default Windows: "dos" = "\r\n" = <CR><NL>, Unix: "unix" = "\n" = <NL>)
vim.opt.fsync = true                    -- 每次保存时调用fsync写入物理硬件中, 而不是留在内存缓存。(default on)

vim.opt.hlsearch = true                 -- 高亮所有匹配搜索的内容
vim.opt.incsearch = true                -- 实时预览搜索的结果
vim.opt.iminsert = 0                    -- 决定插入模式的输入模式, 设置为2使用外部输入法IM。(default 0)
vim.opt.imsearch = 0                    -- 决定搜索模式的输入模式, (default -1 与iminsert相同行为) 0为lmap和IM关闭, 1为lmap开IM关
vim.opt.inccommand = "split"            -- 使用替换命令时的显示效果, 如: ":%s/foo/bar/g"在(default "nosplit")下会在缓冲区实时预览, 而"split"会在下方小窗口显示屏幕外的预览, ""不显示
vim.opt.autoindent = false              -- 自动缩进, 继承上一行缩进
vim.opt.smartindent = true              -- 智能缩进

vim.opt.clipboard = "unnamedplus"       -- 系统剪切板支持(unnamedplus: *寄存器)(unnamed: +寄存器)
-- vim 的 d 键附带剪切会把系统剪切板搞乱?

vim.opt.ignorecase = false              -- 搜索忽略大小写
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

vim.opt.timeoutlen = 500                -- 等待按键序列继续输入的时间(ms), 影响 <C-x> 这类前缀键
vim.opt.ttimeoutlen = 50                -- 终端按键序列(Alt 等)的等待时间(ms), 越小 <Esc> 越跟手

-- Folding: 由 treesitter 提供折叠层级, 没有 parser 的语言不折叠
-- 常用: za 开关当前折叠, zR 全部展开, zM 全部折叠, zc 折叠当前块
vim.opt.foldmethod = "expr"             -- 使用表达式计算折叠
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"  -- treesitter 折叠表达式
vim.opt.foldlevel = 99                  -- 打开文件时展开所有折叠
vim.opt.foldlevelstart = 99             -- 同 foldlevel, 只作用于新打开的文件

-- 拼写检查(spell) --
-- 默认关闭: 不显示任何拼写波浪线。需要时按 <leader>us 临时打开(只影响当前窗口)
vim.opt.spell = false
-- 下面几项只在打开拼写后才起作用, 保留是为了"一打开就是可用状态":
-- en: 检查英文错拼; cjk: nvim 的特殊值, 中日韩字符不会被标成错误(见 :help spell-cjk)
-- 注意: nvim 没有中文词库(spelllang 里不存在 zh), 所以中文只能做到"不检查", 无法查错别字
vim.opt.spelllang = "en,cjk"
vim.opt.spelloptions = "camel"          -- CamelCase 拆成多个单词检查, 写技术文档时少很多误报
-- zg/zw 加的词存在这里; 需要同时有编译产物 tech.en.utf-8.add.spl 才会在启动时生效:
--   编辑 .add 之后执行  :mkspell! ~/.config/nvim/spell/tech.en.utf-8.add
vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/tech.en.utf-8.add"
vim.fn.mkdir(vim.fn.stdpath("config") .. "/spell", "p")

-- FileType 相关设置 --
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "text", "gitcommit" },
    callback = function()
        vim.opt_local.wrap = true               -- 长行自动换行
        vim.opt_local.linebreak = true          -- 在单词边界换行
        -- vim.opt_local.spell = true           -- 已关闭: 不显示拼写波浪线; 需要时按 <leader>us 临时开
    end,
})

-- 外部程序修改文件后自动重新加载(用 autoread), 从别的程序切回 nvim 时生效 -- 看 log 很有用
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    command = "checktime",
})

-- 二进制文件(没有 filetype 且前 1KB 含 NUL 字节)给出提示: 用 <leader>uh 看 hex
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function(args)
        if vim.bo[args.buf].filetype ~= "" or vim.bo[args.buf].buftype ~= "" then
            return
        end
        local name = vim.api.nvim_buf_get_name(args.buf)
        if name == "" or vim.fn.filereadable(name) ~= 1 then
            return
        end
        local head = vim.fn.readfile(name, "", 1)
        if head[1] and head[1]:find("\0", 1, true) then
            vim.bo[args.buf].binary = true
            vim.schedule(function()
                vim.notify("二进制文件: 按 <leader>uh 切换 hex 视图", vim.log.levels.INFO)
            end)
        end
    end,
})

-- Reading docs: https://neovim.io/doc/user/options/#'iconstring' to 'quickfixtextfunc'
