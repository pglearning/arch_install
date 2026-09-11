return {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
        -- 官方选项(以下均为默认值): enable / multiwindow / max_lines / min_window_height /
        -- line_numbers / multiline_threshold / trim_scope / mode / separator / zindex / on_attach
        max_lines = 0,                  -- <= 0 表示不限行数, 也可写 "30%" 这样的百分比
        multiline_threshold = 20,       -- 单个上下文最多显示的行数
        mode = "cursor",                -- "cursor"(按光标行) 或 "topline"(按窗口首行)
        trim_scope = "outer",           -- 超出 max_lines 时丢弃哪部分: "inner" | "outer"
        -- separator = "-",             -- 设置后只在上下文 >= 2 行时显示, 便于区分
    },
}
