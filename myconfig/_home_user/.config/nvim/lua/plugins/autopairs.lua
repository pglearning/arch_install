return {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    opts = {
        -- 官方默认值: map_cr=true / map_bs=true / map_c_h=false / map_c_w=false /
        -- disable_in_macro=true / disable_in_replace_mode=true / disable_in_visualblock=false /
        -- enable_moveright=true / enable_afterquote=true / enable_check_bracket_line=true /
        -- enable_bracket_in_quote=true / break_undo=true / check_ts=false / enable_abbr=false /
        -- ignored_next_char=[[[%w%%%'%[%"%.%`%$]]]
        --
        -- 注意: 这里是整体替换官方默认列表, 所以要把官方那三个也写上
        disable_filetype = {
            "TelescopePrompt", "spectre_panel", "snacks_picker_input",   -- 官方默认
            "yazi",                     -- yazi 文件管理器(终端 buffer)
            "xxd",                      -- hex 视图(<leader>uh)里不要自动补括号
            "DiffviewFiles", "DiffviewFileHistory",   -- diffview 的面板里也不要
        },
        -- 括号补全由 autopairs 负责, blink.cmp 那边的 auto_brackets 已在 blink.lua 里关掉
        --
        -- 可选(官方默认 false): 用 treesitter 判断光标是否在字符串/注释里, 更准但略慢
        -- check_ts = true,
        -- 想要更激进的补全(在括号后继续输入右括号时跳到外面): enable_moveright 默认已开
        -- 需要 wrap 功能(选中文字后输入括号自动包裹): fast_wrap = {}
    },
}
