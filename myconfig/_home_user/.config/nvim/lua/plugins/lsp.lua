return {
    -- Mason for installing LSP servers
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                -- lua
                "stylua",
                "lua-language-server",
                -- bash
                "shfmt",
                "bash-language-server",
                -- python
                "ruff",
                "ty",
                -- go
                "gofumpt",
                "goimports",
                "gopls",
                -- config
                "json-lsp",
                "jsonlint",
                "yaml-language-server",
                "taplo",
                -- frontend
                "css-lsp",
                "prettier",
                "vtsls",
                "tailwindcss-language-server",
                -- c/cpp
                "clangd",
                "cmakelang",
                "cmakelint",
                "neocmakelsp",
            },
        },
    },

    -- Mason LSP config bridge
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
        opts = {},
    },

    -- Main LSP configuration with Blink.cmp integration
    {
        "neovim/nvim-lspconfig",
        dependencies = { "saghen/blink.cmp" },

        config = function()
            -- Get Blink.cmp capabilities
            local capabilities = require("blink.cmp").get_lsp_capabilities()

            -- Diagnostic configuration
            vim.diagnostic.config({
                update_in_insert = true,
                virtual_text = true,
                underline = true,
                severity_sort = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "",
                        [vim.diagnostic.severity.WARN] = "",
                        [vim.diagnostic.severity.INFO] = "",
                        [vim.diagnostic.severity.HINT] = "",
                    },
                },
            })

            -- Enable inlay hints globally
            vim.lsp.inlay_hint.enable(true)

            -- bash-language-server
            vim.lsp.config("bashls", {
                capabilities = capabilities,
                filetypes = { "sh", "bash", "zsh" },
                settings = {
                    bashIde = {
                        globPattern = "*@(.sh|.inc|.bash|.command|.zshrc|.zshprofile)",
                    },
                },
            })

            -- clangd
            vim.lsp.config("clangd", {
                capabilities = capabilities,
                cmd = {
                    "clangd",
                    "--clang-tidy",
                    "--all-scopes-completion",
                    "--completion-style=detailed",
                    "--header-insertion=iwyu",
                    "--pch-storage=disk",
                    "--log=error",
                    "--j=12",
                    "--background-index",
                    "--function-arg-placeholders=0",
                    -- "--fallback-style=file",
                    "--query-driver=**",
                    "--suggest-missing-includes",
                    "--cross-file-rename",
                    "--header-insertion-decorators",
                },
                init_options = {
                    compilationDatabasePath = "./build",
                    usePlaceholders = true,
                    completeUnimported = true,
                    clangdFileStatus = true,
                },
            })

            -- css-lsp
            vim.lsp.config("cssls", {
                capabilities = capabilities,
                settings = {
                    css = {
                        lint = {
                            unknownAtRules = "ignore",
                        },
                    },
                    scss = {
                        lint = {
                            unknownAtRules = "ignore",
                        },
                    },
                    less = {
                        lint = {
                            unknownAtRules = "ignore",
                        },
                    },
                },
            })

            -- lua-language-server
            local library = {
                vim.env.VIMRUNTIME,
                "/usr/share/ura/runtime/",
            }
            vim.lsp.config("lua_ls", {
                capabilities = capabilities,
                settings = {
                    Lua = {
                        runtime = {
                            version = "LuaJIT",
                        },
                        workspace = { library = library },
                        telemetry = { enable = false },
                        diagnostics = {
                            globals = { "vim", "ura", "Snacks" },
                        },
                    },
                },
            })

            -- taplo (toml)
            vim.lsp.config("taplo", {
                capabilities = capabilities,
                root_markers = { ".git", "*.toml" },
            })

            -- yaml-language-server
            vim.lsp.config("yamlls", {
                capabilities = capabilities,
                settings = {
                    yaml = {
                        format = { trailingComma = false },
                    },
                },
            })

            -- Apply all LSP configurations
            vim.lsp.enable({
                "bashls",
                "clangd",
                "cssls",
                "lua_ls",
                "taplo",
                "yamlls",
            })
        end,
    },
}
