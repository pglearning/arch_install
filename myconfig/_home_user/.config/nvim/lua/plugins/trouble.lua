return {
    "folke/trouble.nvim",
    -- 依赖: 无(nui.nvim 在 v3 已经不是依赖了); nvim-web-devicons 可选
    cmd = "Trouble",
    keys = {
        -- 官方推荐的 6 个映射, 这里统一收敛到 <leader>x 分组下
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Trouble: 全部诊断" },
        { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Trouble: 当前 buffer 诊断" },
        { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Trouble: quickfix 列表(make 的编译错误在这)" },
        { "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Trouble: location list" },
        { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Trouble: 文件符号(函数/结构体列表)" },
        { "<leader>xr", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "Trouble: LSP 定义/引用" },
    },
    opts = {
        -- 官方选项(默认值): debug=false / auto_close=false / auto_open=false / auto_preview=true /
        -- auto_refresh=true / auto_jump=false / focus=false / restore=true / follow=true /
        -- indent_guides=true / max_items=200 / multiline=true / pinned=false / warn_no_results=true /
        -- open_no_results=false / win={} / preview={type="main",scratch=true} / throttle / keys / modes / icons
        --
        -- 注意: auto_open 写在全局会报警告并被忽略, 必须写在 mode 上, 例如:
        -- modes = { diagnostics = { auto_open = true } },
        -- win = { position = "bottom", size = 10 },   -- 想让列表在右侧: { position = "right", size = 40 }
        --
        -- trouble 窗口内自带的键位(官方默认, 不用自己写):
        --   <cr> 跳转, o 跳转并关闭, <c-s>/<c-v> 分屏/垂直分屏打开, q 关闭, ? 帮助
        --   }/]] 下一个, {/[[ 上一个, p 预览, P 开关预览, i 查看详情
        --   dd 删除当前项, gb 只看当前 buffer, s 按严重级别过滤
        --   zo/zc/za/zR/zM 折叠相关
    },
}
