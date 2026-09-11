-- snacks 的动画(scroll/indent/dim), 必须在 setup 之前设置
vim.g.snacks_animate = false

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
        ---- Emacs style prefix: C-x / M-x ----
        { "<C-x><C-f>", function() Snacks.picker.files() end, desc = "Find file (C-x C-f)" },
        { "<C-x>b", function() Snacks.picker.buffers() end, desc = "Switch buffer (C-x b)" },
        { "<A-x>", function() Snacks.picker.commands() end, desc = "Run command (M-x)" },

        ---- find / file ----
        { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
        { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
        { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Grep word under cursor" },
        { "<leader>fl", function() Snacks.picker.lines() end, desc = "Search in current buffer" },
        { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
        { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent files" },
        { "<leader>fs", function() Snacks.picker.smart() end, desc = "Smart find" },
        { "<leader>fh", function() Snacks.picker.help() end, desc = "Help pages" },
        { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
        { "<leader>fc", function() Snacks.picker.commands() end, desc = "Commands" },
        { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics (picker)" },
        { "<leader>fq", function() Snacks.picker.qflist() end, desc = "Quickfix list (picker)" },

        ---- git (diff/历史 用 diffview, 见 diffview.lua) ----
        { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git status" },
        { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git log" },
        { "<leader>gL", function() Snacks.picker.git_log_file() end, desc = "Git log (current file)" },
        { "<leader>gB", function()
            -- snacks 的 gitbrowse 在非 git 目录会抛错, 这里先判断
            if Snacks.git.get_root() then
                Snacks.gitbrowse()
            else
                vim.notify("gitbrowse: not inside a git repository", vim.log.levels.WARN)
            end
        end, desc = "Open current file in browser" },

        ---- buffer / ui / terminal ----
        { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete buffer, keep layout" },
        { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete other buffers" },
        { "<leader>un", function() Snacks.notifier.show_history() end, desc = "Notification history" },
        { "<leader>uz", function() Snacks.zen() end, desc = "Toggle zen mode" },
        { "<leader>uZ", function() Snacks.zen.zoom() end, desc = "Toggle zoom" },
        { "<F5>", function() Snacks.terminal() end, mode = { "n", "t" }, desc = "Toggle terminal" },
    },
    opts = {
        -- 下面这些模块默认关闭, 必须显式 enabled = true --
        bigfile = { enabled = true },       -- 大文件优化(默认 >=1.5MB 关闭 treesitter/LSP/折行等)
        dashboard = { enabled = true },     -- 启动面板
        indent = { enabled = true },        -- 缩进线
        input = { enabled = true },         -- vim.ui.input 美化
        picker = { enabled = true },        -- 选择器(需要 rg/fd, 已确认系统里有)
        notifier = { enabled = true },      -- vim.notify 美化
        quickfile = { enabled = true },     -- 打开文件先渲染内容
        scope = { enabled = true },         -- 作用域跳转与 ii/ai 文本对象
        scroll = { enabled = true },        -- 平滑滚动
        statuscolumn = {
            enabled = true,                 -- 状态列: 左侧 mark/sign, 右侧 fold
            right = { "fold" },             -- 官方默认 { "fold", "git" }; 没有 gitsigns 就不显示 git 列
        },
        words = { enabled = true },         -- LSP 引用高亮与跳转

        -- 文件树用 oil.nvim, 保持关闭 --
        explorer = { enabled = false },

        -- 默认就可用(无需 enabled)的模块: animate / bufdelete / git / gitbrowse / notify /
        --                                     terminal / toggle / util / win / zen
        styles = {
            notification = {
                wo = { wrap = true },       -- 通知内容自动换行
            },
        },
    },
    config = function(_, opts)
        require("snacks").setup(opts)

        -- 已知问题: snacks 的 indent 模块在 diffview 的缓冲区里可能报 "Invalid window id"
        -- 官方给的按缓冲区关闭方式就是 vim.b[buf].snacks_indent = false
        --
        -- 注意 diffview 的 diff 窗口用的是"原文件"的 filetype(比如 c), 光靠 FileType 匹配不到,
        -- 所以这里加两条判据:
        --   1) buffer 名字以 "diffview://" 开头(diffview 的缓冲区都是:
        --      面板 = diffview:///panels/<uid>/<Name>, 文件 = diffview://<dir>/<context>/<path>)
        --   2) 普通 diff 模式 / diffview 面板的 filetype
        local function disable_indent(buf)
            vim.b[buf].snacks_indent = false
        end

        vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
            callback = function(args)
                local ft = vim.bo[args.buf].filetype
                if ft == "diff" or ft == "DiffviewFiles" or ft == "DiffviewFileHistory"
                    or vim.api.nvim_buf_get_name(args.buf):sub(1, 11) == "diffview://" then
                    disable_indent(args.buf)
                end
            end,
            desc = "diffview/diff 缓冲区中禁用 snacks 缩进线(规避 Invalid window id)",
        })

        -- diffview 自带的钩子: 新的 diff buffer 就绪时触发(此时该 buffer 是当前 buffer)
        vim.api.nvim_create_autocmd("User", {
            pattern = "DiffviewDiffBufRead",
            callback = function()
                disable_indent(vim.api.nvim_get_current_buf())
            end,
            desc = "diffview diff buffer 中禁用 snacks 缩进线",
        })
    end,
}
