return {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,               -- 配色要最早加载, 否则启动时会先闪一下默认主题
    priority = 1000,
    opts = {
        -- 官方选项见 :help catppuccin-options
        flavour = "mocha",      -- 官方默认 "mocha": latte | frappe | macchiato | mocha
        term_colors = true,     -- 官方默认 false, 同时设置终端 16 色
        -- auto_integrations 默认 true: 自动检测已安装插件(diffview/trouble/markview/snacks/
        -- which-key/treesitter-context/mason ...)并套用配色, 不需要手写 integrations
    },
    config = function(_, opts)
        require("catppuccin").setup(opts)
        vim.cmd.colorscheme("catppuccin")
    end,
}
