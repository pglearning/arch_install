-- Keymaps Setting --
-- 只放"不依赖插件"的全局快捷键; 插件自己的快捷键写在 lua/plugins/对应插件.lua 中
vim.g.mapleader = " "                   -- set leader space
vim.g.maplocalleader = "\\"

local keymap = vim.keymap.set

---- Insert ----
keymap("i", "jk", "<Esc>", { desc = "Escape insert mode" })

---- Emacs style prefix: C-x ----
-- 与 Emacs 对齐: C-x C-s 保存, C-x C-c 退出, C-x 2/3/o/0/1 窗口, C-x h 全选, C-x k 关闭 buffer
-- 插件相关的 C-x 绑定写在插件文件里: C-x C-f 找文件 / C-x b 切 buffer (snacks.lua)
keymap("n", "<C-x><C-s>", "<cmd>write<CR>", { desc = "Save buffer (C-x C-s)" })
keymap("n", "<C-x><C-c>", "<cmd>confirm qa<CR>", { desc = "Quit all, ask to save (C-x C-c)" })
keymap("n", "<C-x>h", "ggVG", { desc = "Select whole buffer (C-x h)" })
keymap("n", "<C-x>k", "<cmd>bdelete<CR>", { desc = "Kill current buffer (C-x k)" })
keymap("n", "<C-x>2", "<C-w>s", { desc = "Split window below (C-x 2)" })
keymap("n", "<C-x>3", "<C-w>v", { desc = "Split window right (C-x 3)" })
keymap("n", "<C-x>o", "<C-w>w", { desc = "Switch to other window (C-x o)" })
keymap("n", "<C-x>0", "<C-w>c", { desc = "Delete current window (C-x 0)" })
keymap("n", "<C-x>1", "<C-w>o", { desc = "Delete other windows (C-x 1)" })

---- Emacs style: cancel ----
keymap("n", "<C-g>", "<cmd>nohlsearch<CR>", { desc = "Cancel search highlight (C-g)" })

---- Cursor ----
keymap({ "n", "v", "o" }, "<C-j>", "5j", { desc = "Move down 5 lines" })
keymap({ "n", "v", "o" }, "<C-k>", "5k", { desc = "Move up 5 lines" })

---- Move code / indent ----
-- Visual 模式下的 <C-j>/<C-k> 覆盖上面的整行跳转, 用于上下移动选中块
keymap("v", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
keymap("v", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })
keymap("v", ">", ">gv", { desc = "Indent and keep selection" })
keymap("v", "<", "<gv", { desc = "Outdent and keep selection" })

---- Highlight / search ----
keymap({ "n", "v", "o" }, "<leader>nh", "<cmd>nohlsearch<CR>", { desc = "No highlight" })
keymap({ "n", "o" }, "<leader>F", "/<C-r><C-w><CR>", { desc = "Search word under cursor" })

---- Spell ----
keymap("n", "<leader>us", function()
    vim.wo.spell = not vim.wo.spell
    vim.notify("spell: " .. (vim.wo.spell and ("on (" .. vim.o.spelllang .. ")") or "off"))
end, { desc = "Toggle spell check" })

---- Replace (Emacs M-%) ----
-- 光标停在 // 之间, 直接输入替换内容即可; I 表示忽略大小写
keymap("n", "<leader>r", ":%s/\\<<C-r><C-w>\\>//gI<Left><Left><Left><Left>", { desc = "Replace word in buffer" })
keymap("v", "<leader>r", ":s/\\<<C-r><C-w>\\>//gI<Left><Left><Left><Left>", { desc = "Replace word in selection" })
keymap("n", "<leader>R", ":%s/\\<<C-r><C-w>\\>//gcI<Left><Left><Left><Left>", { desc = "Replace word in buffer, confirm each" })
keymap("v", "<leader>R", ":s/\\<<C-r><C-w>\\>//gcI<Left><Left><Left><Left>", { desc = "Replace word in selection, confirm each" })

---- File ----
keymap({ "n", "v", "o" }, "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
keymap({ "n", "v", "o" }, "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })
keymap("n", "<leader>fn", ":vnew ", { desc = "New file in vertical split" })

---- Window ----
-- 更多窗口操作使用 nvim 内建: <C-w>h/j/k/l 切换, <C-w>+/- 高度, <C-w></> 宽度
keymap({ "n", "v", "o" }, "<A-f>", "<C-w>_<C-w>|", { desc = "Maximize current window" })
keymap({ "n", "v", "o" }, "<A-=>", "<C-w>=", { desc = "Equalize window size" })
keymap({ "n", "v", "o" }, "<A-+>", "<cmd>resize +3<CR>", { desc = "Increase window height" })
keymap({ "n", "v", "o" }, "<A-->", "<cmd>resize -3<CR>", { desc = "Decrease window height" })
keymap({ "n", "v", "o" }, "<A-.>", "<cmd>vertical resize +5<CR>", { desc = "Increase window width" })
keymap({ "n", "v", "o" }, "<A-,>", "<cmd>vertical resize -5<CR>", { desc = "Decrease window width" })

---- Make (C/C++ 日常) ----
-- :make 调用 makeprg(默认 make) 并把编译错误放进 quickfix, 用 <leader>xq 打开 trouble 查看
keymap("n", "<leader>mm", "<cmd>make<CR>", { desc = "Run make, fill quickfix" })

---- Format ----
-- 有 LSP 格式化能力就交给 LSP(clangd/lua_ls/ruff/jsonls/yamlls/taplo ...),
-- 没有的(比如 bash/markdown)就用外部工具; 不依赖任何格式化插件
local external_formatters = {
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },
    markdown = { "prettier", "--stdin-filepath", "$FILE" },
    cmake = { "cmake-format", "-" },
    -- web: HTML/CSS 和 TS 优先由 LSP 格式化(html/cssls/ts_ls 都支持),
    --      这里是没有挂上 LSP 时的回退
    html = { "prettier", "--stdin-filepath", "$FILE" },
    css = { "prettier", "--stdin-filepath", "$FILE" },
    scss = { "prettier", "--stdin-filepath", "$FILE" },
    less = { "prettier", "--stdin-filepath", "$FILE" },
    javascript = { "prettier", "--stdin-filepath", "$FILE" },
    javascriptreact = { "prettier", "--stdin-filepath", "$FILE" },
    typescript = { "prettier", "--stdin-filepath", "$FILE" },
    typescriptreact = { "prettier", "--stdin-filepath", "$FILE" },
}

local function format(range)
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        if client:supports_method("textDocument/formatting") then
            vim.lsp.buf.format({ async = true })
            return
        end
    end

    local cmd = external_formatters[vim.bo.filetype]
    if not cmd then
        vim.notify("没有可用的格式化器 (filetype: " .. (vim.bo.filetype ~= "" and vim.bo.filetype or "?") .. ")",
            vim.log.levels.WARN)
        return
    end
    local file = vim.api.nvim_buf_get_name(0)
    local parts = {}
    for _, part in ipairs(cmd) do
        parts[#parts + 1] = part == "$FILE" and vim.fn.shellescape(file) or part
    end
    if vim.fn.executable(parts[1]) ~= 1 then
        vim.notify(parts[1] .. " 未安装 (:Mason 里可以装)", vim.log.levels.WARN)
        return
    end
    vim.cmd(range .. "!" .. table.concat(parts, " "))
end

keymap("n", "<leader>lf", function() format("%") end, { desc = "Format buffer" })
keymap("v", "<leader>lf", function() format("'<,'>") end, { desc = "Format selection" })

---- Hex / binary ----
-- 用 xxd 在十六进制视图与原始内容之间切换
-- 注意: 写入时必须让 nvim 处于 binary 模式, 否则 nvim 会给文件补一个行尾换行, 二进制文件会被写坏
-- 编辑 hex 时注意两点:
--   1. 只有左边的十六进制列会被采纳, 右边的 ASCII 列只是显示(xxd -r 会忽略它)
--   2. 默认 2 字节一组; 想按单字节分组(改单个字节时更不容易误改相邻字节)就把下面改成 " -g 1"
local HEX_XXD_ARGS = ""
local HEX_XXD_REV = "xxd -r"

vim.keymap.set("n", "<leader>uh", function()
    if vim.fn.executable("xxd") ~= 1 then
        vim.notify("hex 视图需要 xxd (pacman -S xxd)", vim.log.levels.WARN)
        return
    end

    if vim.b.hex_mode then
        vim.cmd("%!" .. HEX_XXD_REV)
        vim.b.hex_mode = false
        vim.bo.binary = vim.b.hex_binary_prev or false  -- 还原成进入 hex 之前的状态
        if vim.b.hex_ft_prev ~= nil then
            -- 注意: 二进制文件原本就没有 filetype(空字符串), 这里必须一起还原,
            -- 设置 filetype 会同时触发对应语法(空 filetype 即清掉 xxd 的语法高亮)
            vim.bo.filetype = vim.b.hex_ft_prev
        end
        vim.notify("hex: off")
    else
        local name = vim.api.nvim_buf_get_name(0)
        local size = name ~= "" and vim.fn.getfsize(name) or 0
        if size > 8 * 1024 * 1024 then
            local msg = ("文件 %.1f MB, 转 hex 会比较慢, 继续?"):format(size / 1048576)
            if vim.fn.confirm(msg, "&Yes\n&No", 2) ~= 1 then
                return
            end
        end
        vim.b.hex_binary_prev = vim.bo.binary
        vim.b.hex_ft_prev = vim.bo.filetype
        vim.cmd("%!xxd" .. HEX_XXD_ARGS)
        vim.b.hex_mode = true
        vim.bo.binary = true             -- 关键: 写入时不补行尾换行, 不转换换行符
        -- 把 filetype 设成 xxd: 用 nvim 自带的 syntax/xxd.vim 上色,
        -- 同时自动避开 LSP、treesitter、autopairs、格式化(它们都不认 xxd)
        pcall(vim.treesitter.stop)
        vim.bo.filetype = "xxd"
        vim.notify("hex: on (保存时会自动还原为二进制)")
    end
end, { desc = "Toggle hex view (xxd)" })

local hex_group = vim.api.nvim_create_augroup("UserHexMode", { clear = true })

-- hex 视图下保存: 先还原成二进制再写盘(BufWritePre), 写完再转回 hex(BufWritePost)
vim.api.nvim_create_autocmd("BufWritePre", {
    group = hex_group,
    callback = function(args)
        if not vim.b[args.buf].hex_mode then
            return
        end
        vim.b[args.buf].hex_writing = true
        local ok = pcall(vim.api.nvim_buf_call, args.buf, function()
            vim.cmd("%!" .. HEX_XXD_REV)
        end)
        if not ok then
            -- 转换失败时抛错可以中断写入, 保证文件不被写成 hex 文本
            vim.b[args.buf].hex_writing = false
            error("hex 视图: xxd -r 转换失败, 已取消保存 (文件没有被修改)")
        end
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    group = hex_group,
    callback = function(args)
        if not vim.b[args.buf].hex_mode or not vim.b[args.buf].hex_writing then
            return
        end
        pcall(vim.api.nvim_buf_call, args.buf, function()
            vim.cmd("%!xxd" .. HEX_XXD_ARGS)
        end)
        vim.b[args.buf].hex_writing = false
        vim.bo[args.buf].modified = false
    end,
})
