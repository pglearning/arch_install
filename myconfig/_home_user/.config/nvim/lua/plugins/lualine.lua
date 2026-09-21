return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        options = {
            -- 官方 options 默认值: icons_enabled=true / theme='auto' /
            -- component_separators / section_separators / disabled_filetypes / ignore_focus /
            -- always_divide_middle=true / always_show_tabline=true /
            -- globalstatus=(laststatus==3) / refresh
            theme = "auto",             -- 自动跟随 colorscheme(会用到 catppuccin 的配色)
            globalstatus = false,       -- options.lua 里 laststatus=2, 每个窗口一条
            disabled_filetypes = {
                statusline = { "snacks_dashboard", "yazi" },   -- 启动面板/文件管理器不要状态栏
                winbar = {},
            },
            refresh = { statusline = 1000 },
            -- component_separators / section_separators 保持官方默认(需要 Nerd Font)
        },
        sections = {
            lualine_a = { "mode" },
            -- branch 用的是 lualine 自带的 git 实现, 不需要 gitsigns;
            -- diff 组件需要 gitsigns/mini.diff 才显示内容, 没装就自动为空
            lualine_b = { "branch", "diff", "diagnostics" },
            lualine_c = {
                {
                    "filename",                 -- 相对当前目录的路径(path=1)
                    path = 1,
                    symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
                },
            },
            lualine_x = { "filetype" },
            lualine_y = { "progress" },
            lualine_z = { "location" },
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { { "filename", path = 1 } },
            lualine_x = { "location" },
            lualine_y = {},
            lualine_z = {},
        },
        -- 官方可用扩展: trouble / quickfix / lazy / mason / fugitive / neo-tree / fzf ... (没有 yazi)
        -- 可用扩展里没有 yazi, 所以这里不需要它
        extensions = { "trouble", "quickfix", "lazy", "mason" },
    },
}
