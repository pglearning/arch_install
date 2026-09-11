return {
    "sindrets/diffview.nvim",
    -- 依赖: 无(当前版本已自带 async/path 实现, 不需要 plenary); nvim-web-devicons 可选
    cmd = {
        "DiffviewOpen",
        "DiffviewClose",
        "DiffviewFileHistory",
        "DiffviewToggleFiles",
        "DiffviewFocusFiles",
        "DiffviewRefresh",
        "DiffviewLog",
    },
    keys = {
        { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diff: 工作区 vs 索引" },
        { "<leader>gD", "<cmd>DiffviewFileHistory %<CR>", desc = "Diff: 当前文件的历史" },
        { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Diff: 整个仓库的提交历史" },
        { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Diff: 关闭 diffview" },
        -- 其他常用命令(需要时直接用):
        --   :DiffviewOpen HEAD~2          和某次提交比较
        --   :DiffviewOpen origin/main...HEAD
        --   :DiffviewOpen -- path/to/dir  只看某个目录
        --   :DiffviewFileHistory --range=origin..HEAD
        --   :DiffviewLog                  出问题时看日志
    },
    opts = {
        -- 官方选项(默认值): diff_binaries=false / enhanced_diff_hl=false / git_cmd={"git"} /
        -- use_icons=true / show_help_hints=true / watch_index=true / icons / signs /
        -- view / file_panel / file_history_panel / commit_log_panel / default_args / hooks / keymaps
        enhanced_diff_hl = true,        -- 非默认: 更精确的 diff 高亮(需要 termguicolors, 已开)
        view = {
            default = { layout = "diff2_horizontal", winbar_info = true },        -- winbar_info 默认 false
            file_history = { layout = "diff2_horizontal", winbar_info = true },
            merge_tool = { layout = "diff3_horizontal", disable_diagnostics = true, winbar_info = true },
        },
        file_panel = {
            listing_style = "tree",     -- 官方默认值
            win_config = { position = "left", width = 35 },
        },
        file_history_panel = {
            win_config = { position = "bottom", height = 16 },
        },
        -- 键位用官方默认(buffer-local, 只在 diffview 的窗口里生效):
        --   文件面板: <cr> 打开, - / s 暂存 hunk, S 全部暂存, U 全部取消暂存,
        --             X 还原文件, i 切换 tree/flat, f 折叠目录, R 刷新, g? 帮助
        --   diff 窗口: <tab>/<s-tab> 上/下一个文件, <leader>e 聚焦文件面板,
        --             <leader>b 显示/隐藏文件面板, g<C-x> 换布局,
        --             冲突时: <leader>co/ct/cb 选 ours/theirs/base, dx 删除冲突区
        -- 想在 diffview 里禁用某个默认键: keymaps = { view = { ["<leader>b"] = false } }
    },
}
