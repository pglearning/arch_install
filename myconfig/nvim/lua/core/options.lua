vim.opt.number = true                   -- 显示行号
vim.opt.relativenumber = true           -- 相对行号, 显示当前光标位置行号，其他为相对光标位置的行号距离

vim.opt.history = 1000                  -- Max history command
vim.opt.tabstop = 4                     -- Tab 显示宽度
vim.opt.shiftwidth = 4                  -- 自动缩进宽度
vim.opt.expandtab = true                -- 将 Tab 转换为空格
vim.opt.wrap = false                    -- 自动换行
vim.opt.cursorline = true               -- 显示光标

vim.opt.autoread = true                 -- 如果当前文件被外部程序修改, 会重新加载该文件
vim.opt.autowrite = false               -- 自动保存
vim.opt.confirm = true                  -- Unsave file and readonly file confim hint
vim.opt.undofile = true                 -- Save undo history to file
vim.opt.undolevels = 1000               -- Max number of undo change

vim.opt.showmatch = true                -- Highlight match symbol, not working?
vim.opt.matchtime = 1                   -- Highlight match symbol time, not working?
vim.opt.hlsearch = true                 -- Search text highlight
vim.opt.incsearch = true                -- Show result Search immediately
vim.opt.autoindent = true               -- 自动缩进, 继承上一行缩进
vim.opt.smartindent = true              -- 智能缩进

vim.opt.mouse:append("a")               -- 启用鼠标支持, vim.opt.mouse = 'a'
vim.opt.clipboard:append("unnamedplus") -- 系统剪切板支持(unnamedplus: *寄存器)(unnamed: +register), vim 的 d 键附带剪切会把系统剪切板搞乱?

vim.opt.ignorecase = true               -- 搜索忽略大小写
vim.opt.smartcase = true                -- 智能大小写搜索

vim.opt.autochdir = false               -- auto change working dir same as file dir

-- Window
vim.opt.splitbelow = true               -- 默认新窗口为下边
vim.opt.splitright = true               -- 默认新窗口为右边
vim.opt.equalalways = true              -- Split window always same width and height

vim.opt.signcolumn = "yes"              -- 左侧多一列，可以方便debug和插件提示
vim.opt.termguicolors = true            -- 启用真彩色，支持外观主题
