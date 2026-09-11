return {
    -- LSP 本体: nvim 0.11+ 的官方写法是 vim.lsp.config() 配置, vim.lsp.enable() 启用 --
    {
        "neovim/nvim-lspconfig",
        dependencies = { "saghen/blink.cmp" },
        config = function()
            -- 用 "*" 一次性给所有 server 加上 blink.cmp 的补全能力
            -- (会与 nvim-lspconfig 里 lsp/<name>.lua 的默认值深合并, 不会丢东西)
            vim.lsp.config("*", {
                capabilities = require("blink.cmp").get_lsp_capabilities(),
            })

            -- 诊断显示 --
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

            -- 内联提示(C/C++ 的参数名等), <leader>li 可随时开关
            vim.lsp.inlay_hint.enable(true)
            vim.keymap.set("n", "<leader>li", function()
                local enabled = vim.lsp.inlay_hint.is_enabled()
                vim.lsp.inlay_hint.enable(not enabled)
                vim.notify("Inlay hints " .. (enabled and "disabled" or "enabled"))
            end, { desc = "Toggle inlay hints" })

            -- clangd (使用系统 /usr/bin/clangd, 不走 mason) --
            vim.lsp.config("clangd", {
                cmd = {
                    "clangd",
                    "--clang-tidy",                     -- 启用 clang-tidy 检查(需要项目里有 .clang-tidy)
                    "--all-scopes-completion",          -- 补全包含全局作用域
                    "--completion-style=detailed",      -- 补全显示完整签名
                    "--header-insertion=iwyu",          -- 自动插入头文件
                    "--header-insertion-decorators",
                    "--pch-storage=disk",               -- PCH 存磁盘, 省内存
                    "--background-index",               -- 后台建索引(会在项目根目录生成 .cache/clangd/,
                                                        --   不想看到它就在 ~/.config/git/ignore 里加 .cache/)
                    "--function-arg-placeholders=0",    -- 补全函数时不插入参数占位符
                    "--suggest-missing-includes",       -- 提示缺失的 include
                    "--cross-file-rename",              -- 跨文件重命名
                    "--query-driver=**",                -- 允许查询任意编译器(交叉编译时需要)
                    "--log=error",
                    "--j=12",                           -- 后台并行任务数
                    -- "--fallback-style=file",
                },
                init_options = {
                    -- 编译数据库位置(clangd 也会自动在项目根目录和 build/ 下找 compile_commands.json)
                    compilationDatabasePath = "./build",
                    -- 下面三个是 clangd 旧参数, 已被上面的命令行参数取代, 同时写会互相冲突:
                    -- usePlaceholders = true,        --> --function-arg-placeholders
                    -- completeUnimported = true,     --> --all-scopes-completion
                    -- clangdFileStatus = true,       --> 已废弃
                },
            })

            -- bash-language-server (装了 shellcheck 会自动用它做诊断) --
            vim.lsp.config("bashls", {
                filetypes = { "sh", "bash", "zsh" },    -- 官方默认 { "bash", "sh" }, 这里补上 zsh
                settings = {
                    bashIde = {
                        globPattern = "*@(.sh|.inc|.bash|.command|.zshrc|.zshprofile)",
                    },
                },
            })

            -- lua-language-server --
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        workspace = {
                            library = {
                                vim.env.VIMRUNTIME,
                                "/usr/share/ura/runtime/",
                            },
                            -- checkThirdParty = false,   -- 官方默认会弹窗询问第三方库, 需要时打开
                        },
                        telemetry = { enable = false },
                        diagnostics = { globals = { "vim", "ura", "Snacks" } },
                    },
                },
            })

            -- yaml-language-server --
            vim.lsp.config("yamlls", {
                settings = {
                    -- 注意: yaml.format.trailingComma 不是 yaml-language-server 的合法选项
                    -- 官方默认: yaml.format.enable = true (允许 LSP 格式化)
                    yaml = { format = { enable = true } },
                },
            })

            -- taplo (toml) --
            vim.lsp.config("taplo", {
                -- 官方默认 { ".taplo.toml", "taplo.toml", ".git" }
                root_markers = { ".git", "*.toml" },
            })

            -- web: HTML / CSS / Emmet / JS + TS --
            vim.lsp.config("cssls", {
                settings = {
                    -- 避免 Tailwind / 自定义 @rule 被报成错误
                    css = { lint = { unknownAtRules = "ignore" } },
                    scss = { lint = { unknownAtRules = "ignore" } },
                    less = { lint = { unknownAtRules = "ignore" } },
                },
            })
            -- 下面三个用官方默认配置就够了, 所以不再写 vim.lsp.config:
            --   html  : 补全依赖 snippet 能力, blink.cmp 已经在 capabilities 里打开了;
            --           它同时给 <style>/<script> 里的 CSS/JS 提供补全
            --   emmet : 在 html/css/scss/less/jsx/tsx/vue/svelte 里展开简写
            --   ts_ls : 有 tsconfig.json / jsconfig.json 就按项目配置, 没有也能单文件工作
            --           (格式化交给 LSP/prettier; 内联提示用 <leader>li 开关)

            -- 启用 (mason 装好但没在这里列出的 server 会由 automatic_enable 自动启用) --
            vim.lsp.enable({
                "bashls",
                "clangd",
                "cssls",
                "emmet_language_server",
                "html",
                "jsonls",
                "lua_ls",
                "neocmake",
                "ruff",
                "taplo",
                "ts_ls",
                "ty",
                "yamlls",
            })

            -- 按键: nvim 0.12 已内建 grn(rename) / gra(code action) / grr(references) /
            --       gri(implementation) / grt(type definition) / grx(codelens) / gO(symbol) /
            --       K(hover) / i_<C-S>(signature) / ]d [d(诊断), 这里只补两个别名
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if not client then
                        return
                    end

                    vim.keymap.set("n", "gd", vim.lsp.buf.definition,
                        { buffer = args.buf, desc = "Go to definition" })

                    -- 只给 clangd: 头文件里声明后, 在源文件一键生成函数定义
                    if client.name == "clangd" then
                        vim.keymap.set("n", "<leader>lc", function()
                            vim.lsp.buf.code_action({
                                filter = function(action)
                                    return action.title:find("Generate definition") ~= nil
                                end,
                                apply = true,
                            })
                        end, { buffer = args.buf, desc = "clangd: generate definition" })
                    end
                end,
            })
        end,
    },
}
