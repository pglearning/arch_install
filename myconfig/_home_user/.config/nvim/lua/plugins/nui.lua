return {
    "MunifTanjim/nui.nvim",
    lazy = true,
    -- 说明: 当前这套插件里没有插件硬依赖它(trouble.nvim v3 起已不再需要 nui;
    -- which-key/snacks/markview/diffview/oil 都不依赖它), 所以它不会主动加载。
    -- 保留它是为了以后加依赖 nui 的插件时不用再找(例如 neo-tree.nvim)。
    -- 官方只有 setup 相关的组件 API, 没有用户级 opts/keymaps/命令, 不需要配置。
}
