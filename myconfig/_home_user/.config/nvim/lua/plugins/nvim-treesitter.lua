-- nvim-treesitter (main 分支 v2 重写版, 需要 Neovim 0.12+)
-- 该插件只负责 安装/更新 parser 并提供 queries; 高亮/折叠需要自己在 FileType 里开启(见下面)
-- 安装 parser 需要外部依赖: tree-sitter-cli (Arch: sudo pacman -S tree-sitter-cli) + C 编译器
-- 没有 tree-sitter-cli 时, Neovim 自带的 parser(c / lua / markdown / vim / vimdoc / query)仍然可用

local parsers = {
    -- 日常: C/C++、python、bash、markdown、lua
    "c", "cpp", "python", "bash", "markdown", "markdown_inline", "lua",
    -- web: HTML / CSS / JS / TS(含 JSX/TSX)
    "html", "css", "scss", "javascript", "typescript", "tsx",
    -- 配置与工程文件
    "json", "yaml", "toml", "cmake", "make", "diff", "gitcommit", "vim", "vimdoc", "query",
}

return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,                   -- 官方说明: 该插件不支持懒加载
    build = function()
        -- 官方推荐 build = ":TSUpdate"; 这里在没有 tree-sitter-cli 时跳过, 避免报错
        if vim.fn.executable("tree-sitter") == 1 then
            vim.cmd("TSUpdate")
        end
    end,
    config = function()
        -- 官方推荐的开启方式: 有对应 parser 才 start, 避免 "no parser for ..." 报错
        -- 折叠表达式在 options.lua 里配置: foldexpr = v:lua.vim.treesitter.foldexpr()
        vim.api.nvim_create_autocmd("FileType", {
            callback = function()
                local buf = vim.api.nvim_get_current_buf()
                if vim.treesitter.highlighter.active[buf] then
                    return
                end
                local lang = vim.treesitter.language.get_lang(vim.bo.filetype) or vim.bo.filetype
                if vim.treesitter.language.add(lang) then
                    vim.treesitter.start()
                end
            end,
        })

        -- 安装缺失的 parser (异步, 已装的会跳过)
        if vim.fn.executable("tree-sitter") == 1 then
            require("nvim-treesitter").install(parsers)
        else
            vim.notify(
                "nvim-treesitter: 未找到 tree-sitter-cli, 跳过 parser 安装\n"
                    .. "Arch 上执行: sudo pacman -S tree-sitter-cli\n"
                    .. "(删掉本文件里这段 notify 即可关闭提示)",
                vim.log.levels.WARN
            )
        end
    end,
}
