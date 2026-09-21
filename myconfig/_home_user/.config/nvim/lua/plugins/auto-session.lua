return {
    "rmagatti/auto-session",
    lazy = false,   -- 要在启动时自动恢复 session, 不能懒加载
    keys = {
        { "<leader>ss", "<cmd>AutoSession save<CR>", desc = "Session: 保存当前 session" },
        { "<leader>sr", "<cmd>AutoSession restore<CR>", desc = "Session: 恢复 session" },
        { "<leader>sd", "<cmd>AutoSession delete<CR>", desc = "Session: 删除当前目录的 session" },
        { "<leader>sS", "<cmd>AutoSession search<CR>", desc = "Session: 搜索并切换 session" },
        { "<leader>sp", "<cmd>AutoSession purgeOrphaned<CR>", desc = "Session: 清理孤立 session 文件" },
    },
    opts = {
        -- 这个版本用新的配置名(auto_session_* 是旧名, 会被兼容但会有告警)
        -- 官方默认值: enabled=true / auto_save=true / auto_restore=true / auto_create=true /
        -- auto_restore_last_session=false / cwd_change_handling=false / single_session_mode=false /
        -- suppressed_dirs=nil / allowed_dirs=nil / bypass_save_filetypes=nil /
        -- close_filetypes_on_save={ "checkhealth" } / close_unsupported_windows=true /
        -- git_use_branch_name=false / auto_delete_empty_sessions=true / purge_after_minutes=nil /
        -- args_allow_single_directory=true / args_allow_files_auto_save=false / log_level="error" /
        -- root_dir=stdpath("data").."/sessions/" / show_auto_restore_notif=false /
        -- continue_restore_on_error=true / lsp_stop_on_restore=false / save_and_restore_shada=false /
        -- lazy_support=true / legacy_cmds=true / session_lens={...}

        -- 放到 state 目录(默认在 data 目录), 都在项目目录之外, 不会污染工程
        root_dir = vim.fn.stdpath("state") .. "/sessions/",

        -- 官方默认 nil(任何目录都会建 session 文件); 这些目录里不再生成/恢复 session
        -- 注意: 匹配是"整条路径"锚定的, "/" 只匹配根目录本身, 所以 /tmp 要写 /tmp 和 /tmp/**
        suppressed_dirs = { "~/", "~/Downloads", "~/Documents", "/", "/tmp", "/tmp/**" },

        -- 只有这些 filetype 的 buffer 打开时不保存 session(避免为启动面板/文件管理器建空 session)
        bypass_save_filetypes = { "snacks_dashboard", "yazi" },

        -- 非默认: 30 天没访问过的 session 自动清理(设成 nil 可关闭)
        purge_after_minutes = 60 * 24 * 30,

        -- sessionoptions 在 options.lua 里已按官方推荐设置, 否则恢复后 filetype/高亮会错乱
        -- session 选择器: picker 会自动检测(这里装了 snacks, 会直接用 snacks)
        -- session_lens = { picker = "snacks", previewer = "summary" },
    },
}
