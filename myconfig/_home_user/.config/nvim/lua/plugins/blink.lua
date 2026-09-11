return {
    "saghen/blink.cmp",
    dependencies = { "rafamadriz/friendly-snippets" },
    version = "1.*",
    event = "VeryLazy",
    -- build = "cargo build --release",     -- 默认使用官方预编译的 fuzzy 二进制
    opts = {
        -- 官方顶层配置项: enabled / keymap / appearance / completion / signature /
        --                 sources / fuzzy / snippets / cmdline / term
        keymap = {
            -- 可选: "default" | "super-tab" | "enter" | "none" (cmdline 模式还支持 "cmdline"/"inherit")
            preset = "super-tab",
        },
        appearance = {
            nerd_font_variant = "mono",     -- 官方默认值
        },
        completion = {
            documentation = {
                auto_show = true,           -- 官方默认 false
                -- auto_show_delay_ms = 500,
            },
            accept = {
                -- 括号补全交给 nvim-autopairs, 关掉 blink 自己的自动括号,
                -- 否则接受函数补全时 blink 插入的 () 会和 autopairs 重复
                auto_brackets = { enabled = false },
            },
            -- list = { max_items = 200, selection = { preselect = true, auto_insert = true } },
            -- ghost_text = { enabled = false },       -- 行内灰色预览(默认关闭)
        },
        signature = {
            enabled = true,                 -- 官方默认 false; C/C++ 看函数签名用 <C-k>
        },
        sources = {
            -- 官方默认 { "lsp", "path", "snippets", "buffer" }
            default = { "path", "snippets", "buffer", "lsp" },
        },
        fuzzy = {
            implementation = "prefer_rust_with_warning",    -- 官方默认值
        },
        cmdline = {
            keymap = { preset = "super-tab" },              -- 官方默认 preset 是 "cmdline"
            completion = { menu = { auto_show = true } },   -- 官方默认只在 cmdwin 中自动弹出
        },
    },
}
