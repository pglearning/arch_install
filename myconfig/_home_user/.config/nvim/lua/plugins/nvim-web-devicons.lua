return {
    "nvim-tree/nvim-web-devicons",
    lazy = true,                -- 只作为 lualine / markview 等插件的依赖按需加载
    -- 不需要 setup(): 直接 require("nvim-web-devicons").get_icon(...) 即可
    -- 官方选项(想改图标时取消注释): override / default / strict / color_icons / variant
}
