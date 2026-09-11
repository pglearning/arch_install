return {
    "OXY2DEV/markview.nvim",
    -- 依赖: nvim-treesitter(markdown / markdown_inline 解析器) + nvim-web-devicons(可选)
    lazy = false,   -- 官方明确要求: 不要懒加载(它内部已经按需渲染), 懒加载反而会更慢
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    keys = {
        { "<leader>Mm", "<cmd>Markview toggle<CR>", desc = "Markdown: 开关渲染" },
        { "<leader>Mh", "<cmd>Markview hybridToggle<CR>", desc = "Markdown: 混合模式(光标行显示源码)" },
        { "<leader>Mp", "<cmd>Markview splitToggle<CR>", desc = "Markdown: 分屏预览" },
    },
    opts = {
        -- 官方顶层选项: markdown / markdown_inline / latex / typst / html / yaml / asciidoc /
        -- comment / preview / experimental / icon_provider ... (默认全部开启渲染)
        --
        -- 注意: conceallevel 由 markview 自己按窗口管理(渲染时设 3, 关闭时设回 0),
        -- 所以不要在 options.lua 里给 markdown 另设 conceallevel
        --
        -- 常用调整(官方默认值):
        --   preview = {
        --     hybrid_modes = { "i" },        -- 插入模式进入 hybrid
        --     icon_provider = "devicons",    -- 可选 "internal" | "devicons" | "mini"
        --     splitview_win = { ... },       -- :Markview splitToggle 的窗口
        --   },
        --   markdown = {
        --     headings = { shift_width = 0 },              -- 标题图标缩进
        --     code_blocks = { style = "language", ... },   -- 代码块样式
        --     tables = { enable = true },
        --   },
        --   latex = { enable = true },       -- 数学公式(需要 latex 渲染工具, 没装则保持默认)
        -- 完整选项见 :help markview 或仓库 doc/markview.nvim.txt
        --
        -- 其它可用命令: :Markview Enable/Disable/Toggle(全局), :Markview enable/disable/toggle(当前 buffer),
        --              :Markview linewiseToggle, :Markview splitOpen/splitClose, :Markview open(独立窗口预览)
        --
        -- 注意两件事:
        -- 1. markview 会在 markdown buffer 里把 gx 改成 :Markview open(buffer-local, 用来打开链接),
        --    想保留原生 gx 就设 preview = { map_gx = false }
        -- 2. 只有显式执行 :Markview traceExport 时才会在当前目录写一个 markview_log.txt,
        --    平时(渲染/预览/分屏)完全不会产生任何文件
    },
}
