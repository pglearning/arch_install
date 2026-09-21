return {
    "mikavilpas/yazi.nvim",
    version = "*",                  -- 官方推荐: 跟随最新稳定 tag
    event = "VeryLazy",
    dependencies = {
        -- 官方声明的依赖(用于路径解析), 它是懒加载的, 不会拖慢启动
        { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
        { "<leader>e", "<cmd>Yazi<cr>", desc = "Yazi: 在当前文件所在目录打开" },
        { "-", "<cmd>Yazi<cr>", desc = "Yazi: 在当前文件所在目录打开" },
        { "<leader>E", "<cmd>Yazi cwd<cr>", desc = "Yazi: 在 nvim 工作目录打开" },
        -- 另外还有: :Yazi toggle (继续上次的会话) / :Yazi logs (排查问题)
    },
    opts = {
        -- 官方选项与默认值(见插件 lua/yazi/config.lua):
        --   open_for_directories=false / open_multiple_tabs=false / enable_mouse_support=false /
        --   change_neovim_cwd_on_close=false / clipboard_register="*" / log_level=OFF /
        --   floating_window_scaling_factor=0.9 / yazi_floating_window_winblend=0 /
        --   highlight_hovered_buffers_in_same_directory=true / hooks={...} / integrations={...}
        open_for_directories = false,       -- 保持默认: `nvim .` 仍然用 netrw 打开目录
                                            -- 想让 yazi 接管目录 buffer 就改 true, 并加
                                            -- vim.g.loaded_netrwPlugin = 1 (官方 README 有说明)

        -- 集成: 默认值是 telescope, 但本方案装的 picker 是 snacks,
        -- 不换掉的话在 yazi 里按 <C-s> 会去 require("telescope.builtin") 而报错
        integrations = {
            grep_in_directory = "snacks.picker",
            grep_in_selected_files = "snacks.picker",
            -- 注意: replace_in_directory / replace_in_selected_files 的默认实现要 grug-far.nvim,
            -- 没装的话它内部有 pcall 会给出提示; 这两个功能只由下面那个键位触发, 键位已关掉所以够不着
            -- (Lua 里写 `= nil` 是不生效的, 覆盖不掉默认值, 所以这里干脆不写)
            --
            -- 其余用默认: bufdelete_implementation="bundled-snacks"(用 snacks 关 buffer 并保留窗口布局)
            --             pick_window_implementation="snacks.picker"
        },

        keymaps = {
            -- 官方默认键位(yazi 窗口内生效): <f1> 帮助, <c-v> 垂直分屏打开, <c-x> 水平分屏,
            -- <c-t> 新标签页, <c-s> 在所在目录 grep, <c-g> 在所在目录替换(需要 grug-far),
            -- <tab> 在已打开 buffer 间循环, <c-y> 复制相对路径(需要 realpath), <c-q> 送入 quickfix,
            -- <c-\> 把 nvim 的 cwd 切到该目录, <c-o> 选一个窗口打开
            show_help = "<f1>",
            replace_in_directory = false,   -- grug-far 没装, 去掉这个键位(false = 不映射)
        },

        clipboard_register = "+",   -- 官方默认 "*"; 本配置里 clipboard=unnamedplus, 用 + 保持一致
    },
}
