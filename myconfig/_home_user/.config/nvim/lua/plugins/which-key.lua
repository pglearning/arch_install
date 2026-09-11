return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    opts = {
        preset = "helix",           -- 可选: "classic" | "modern" | "helix" | false
        -- 官方其余选项: delay / filter / notify / triggers / defer / plugins / win / layout /
        --               keys / sort / expand / replace / icons / show_help / show_keys / disable / debug
        spec = {
            {
                mode = { "n", "v" },
                { "<leader>b", group = "buffer" },
                { "<leader>f", group = "find/file" },
                { "<leader>g", group = "git" },
                { "<leader>l", group = "lsp" },
                { "<leader>m", group = "make" },
                { "<leader>M", group = "markdown" },
                { "<leader>s", group = "session" },
                { "<leader>u", group = "ui/toggle" },
                { "<leader>x", group = "diagnostics/quickfix" },
                { "[", group = "prev" },
                { "]", group = "next" },
                { "g", group = "goto" },
                { "z", group = "fold" },
            },
            {
                mode = { "n" },
                { "<C-x>", group = "emacs prefix" },
            },
        },
    },
}
