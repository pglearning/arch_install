return {
    -- Mason: LSP server 与外部工具(格式化/lint)的安装器 --
    {
        "mason-org/mason.nvim",
        -- 注意: mason.nvim 本身没有 ensure_installed 选项, server 的自动安装由 mason-lspconfig 负责
        opts = {
            -- 官方默认值, 列出供参考:
            -- install_root_dir = vim.fn.stdpath("data") .. "/mason"
            -- PATH = "prepend"                  -- 把 mason 的 bin 目录放进 PATH 的方式
            -- max_concurrent_installers = 4
            -- registries = { "github:mason-org/mason-registry" }
            -- ui = { border = nil, backdrop = 60, width = 0.8, height = 0.9, icons = {...} }
        },
    },

    -- mason 与 nvim 0.11+ 原生 vim.lsp.config / vim.lsp.enable 的桥接 --
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
        opts = {
            -- 该版本官方配置项只有两个: ensure_installed / automatic_enable
            -- 这里写 nvim-lspconfig 的 server 名(不是 mason 包名), 装完会自动 enable
            ensure_installed = {
                "lua_ls",       -- lua
                "bashls",       -- bash / sh / zsh
                "ruff",         -- python: lint + format
                "ty",           -- python: 类型检查
                "jsonls",       -- json / jsonc
                "yamlls",       -- yaml
                "taplo",        -- toml
                "neocmake",     -- cmake (C/C++ 项目常用)
                -- web: HTML / CSS / JS / TS
                "html",                  -- HTML
                "cssls",                 -- CSS / SCSS / LESS
                "emmet_language_server", -- HTML/CSS 简写展开(div.box>ul>li*3)
                "ts_ls",                 -- JS / TS; mason 会自动一起装 typescript
                                         -- (registry 里 typescript-language-server 的 extra_packages)
                -- 需要别的语言时取消注释即可(会自动下载对应 server):
                -- "vtsls", "tailwindcss", "biome", "gopls", "marksman", "vue_ls",
            },
            automatic_enable = true,    -- 官方默认值: mason 安装的 server 自动 vim.lsp.enable()
        },
        config = function(_, opts)
            require("mason-lspconfig").setup(opts)

            -- formatter / linter 不属于 LSP, ensure_installed 不支持, 这里用官方 API 补装
            -- (cmake-format 用于 cmake; prettier 用于 markdown; shfmt/shellcheck 用于 bash)
            local tools = { "shellcheck", "shfmt", "prettier", "cmakelang" }
            local registry = require("mason-registry")
            local missing = vim.tbl_filter(function(name)
                return not registry.is_installed(name)
            end, tools)
            if #missing > 0 then
                vim.cmd("MasonInstall " .. table.concat(missing, " "))
            end
        end,
    },
}
