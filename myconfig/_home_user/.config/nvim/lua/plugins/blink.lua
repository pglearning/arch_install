return {
    "saghen/blink.cmp",
    dependencies = { "rafamadriz/friendly-snippets" },
    version = "1.*",
    event = "VeryLazy",
    -- build = "cargo build --release",
    opts = {
        keymap = {
            preset = "super-tab",
            -- ["<C-y>"] = { "select_and_accept" },
        },
        completion = {
            documentation = {
                auto_show = true,
            },
        },
        sources = {
            default = { "path", "snippets", "buffer", "lsp" },
        },
        cmdline = {
            keymap = {
                preset = "super-tab",
            },
            completion = {
                menu = {
                    auto_show = true,
                },
            },
        }
    },
}
