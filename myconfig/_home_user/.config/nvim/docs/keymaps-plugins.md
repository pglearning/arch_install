# 插件与自定义快捷键（新插件方案）

> 列出**本配置添加**的键位：自定义核心键位 + 各插件键位。
> 原生 Neovim 默认键位见 `keymaps-native.md`。
> `mapleader` = `空格`，`maplocalleader` = `\`。

## 0. 文件对照（改键位去对应文件）

| 文件 | 负责的键位 |
|---|---|
| `lua/keymaps/keymaps.lua` | 核心/Emacs 层、make、格式化、hex 视图（不依赖插件） |
| `lua/config/lazy.lua` | `<localleader>l`、`<localleader>h` |
| `lua/plugins/snacks.lua` | 查找/git/buffer/UI 的 leader 键位、`C-x C-f`、`C-x b`、`M-x`、`<F5>` |
| `lua/plugins/oil.lua` | `-`、`<leader>e` |
| `lua/plugins/trouble.lua` | `<leader>x*` |
| `lua/plugins/diffview.lua` | `<leader>g*`（diff/历史） |
| `lua/plugins/markview.lua` | `<leader>M*` |
| `lua/plugins/auto-session.lua` | `<leader>s*` |
| `lua/plugins/lsp.lua` | `<leader>li`、`gd`、`<leader>lc`（后两个 buffer-local） |
| `lua/plugins/blink.lua` | 插入/命令行模式的补全键位 |
| `lua/plugins/autopairs.lua` | 插入模式括号补全（无自定义键位） |

---

## 1. 自定义核心键位（`lua/keymaps/keymaps.lua`）

### 1.1 Emacs 层

| 键 | 作用 |
|---|---|
| `C-x C-f` | 找文件（snacks picker） |
| `C-x b` | 切换 buffer（snacks picker） |
| `C-x C-s` | 保存 |
| `C-x C-c` | 退出所有窗口（未保存会询问） |
| `C-x h` | 全选（`ggVG`） |
| `C-x k` | 关闭当前 buffer |
| `C-x 2` / `C-x 3` | 上下分屏 / 左右分屏 |
| `C-x o` | 切到另一个窗口 |
| `C-x 0` / `C-x 1` | 关闭当前窗口 / 关闭其它窗口 |
| `M-x` (`A-x`) | 命令面板 |
| `C-g` | 取消搜索高亮 |

### 1.2 编辑与移动

| 键 | 模式 | 作用 |
|---|---|---|
| `jk` | i | 退出插入模式 |
| `<C-j>` / `<C-k>` | n/v/o | 下/上移动 5 行 |
| `<C-j>` / `<C-k>` | v | 下/上移动选中的代码块 |
| `>` / `<` | v | 缩进/反缩进并保持选中 |
| `<leader>nh` | n/v/o | 取消搜索高亮 |
| `<leader>F` | n/o | 搜索光标下的单词 |
| `<leader>r` / `<leader>R` | n/v | 用光标下单词替换（`R` 逐个确认） |

### 1.3 文件 / 窗口 / 编译 / 格式化

| 键 | 作用 |
|---|---|
| `<leader>w` / `<leader>q` | 保存 / 关闭当前窗口 |
| `<leader>fn` | 新建文件（垂直分屏） |
| `<A-f>` / `<A-=>` | 当前窗口最大化 / 所有窗口等大 |
| `<A-+>` / `<A-->` | 窗口高度 +3 / -3 |
| `<A-.>` / `<A-,>` | 窗口宽度 +5 / -5 |
| `<leader>mm` | `:make`（编译并把错误放进 quickfix，用 `<leader>xq` 查看） |
| `<leader>lf` | 格式化：有 LSP 就用 LSP（C/C++/lua/python/json/yaml/cmake/toml/HTML/CSS/TS），否则用外部工具（bash→shfmt；markdown、html、css、scss、js、ts→prettier）；visual 模式下只格式化选中范围 |

### 1.4 Hex / 二进制视图

| 键 | 作用 |
|---|---|
| `<leader>uh` | 用 xxd 在十六进制视图和原始内容之间切换 |

- 打开 `.bin`/`.o`/`.elf` 等二进制文件时会提示按 `<leader>uh`（自动检测前 1KB 里的 NUL 字节）。
- 进入 hex 视图时 filetype 会临时变成 `xxd`（用 nvim 自带的 `syntax/xxd.vim` 上色），因此 **LSP / treesitter / 自动补括号 / 格式化都会自动避开**；退出时恢复原 filetype。
- 保存时自动先 `xxd -r` 还原成二进制再写盘，写完再转回 hex；期间 buffer 处于 `binary` 模式，所以**不会**被 nvim 补上多余的行尾换行（这一点写错会把二进制文件写坏）。
- 超过 8MB 的文件会先询问。

**编辑 hex 时的两点注意**（配置里也写了注释）：

1. **只有左边的十六进制列会被采纳**，右边的 ASCII 列纯粹是显示——`xxd -r` 会忽略它（已实测：只改 ASCII 列保存后文件不变）。所以要把 `hello` 改成别的字符串，改的是左边对应的 `68 65 6c 6c 6f`。
2. 默认是 **2 字节一组**（`454c 4600`）。想按单字节分组（改单个字节时不容易误改相邻字节），把 `lua/keymaps/keymaps.lua` 里的 `HEX_XXD_ARGS` 改成 `" -g 1"` 即可（已实测 `xxd -g 1` → `xxd -r` 往返字节一致）。
3. 插入/删除行也可以，但 `xxd -r` 是按行首的地址列定位的，所以新增行要自己把地址列写对；转换失败时会直接中止保存并报错，不会把 hex 文本写进文件。
4. 常用技巧：最左边就是字节偏移量；一行 16 字节，所以跳第 N 行就是第 `(N-1)*16` 字节（`:N` 或 `NG`）；搜索字节序列要搜十六进制列（例如 `/454c 46`，注意 ASCII 列只是显示）。

### 1.5 拼写检查（**默认关闭**）

**默认不显示任何拼写波浪线**：`vim.opt.spell = false`，并且不再对 markdown/text/gitcommit 自动开启。
markdown 仍然自动折行（`wrap` + `linebreak`）。

想用时按 `<leader>us` 临时打开（只影响当前窗口）。打开后是"可用的状态"，不会有中文误报：

- `spelllang = "en,cjk"`：`cjk` 是 nvim 的特殊值，**中日韩字符不会被标成错误**（见 `:help spell-cjk`）。
- 技术名词（`nvim`、`quickfix`、`treesitter`、`diffview`、`LSP`、`JSX`…）已在自定义词表里，不误报；真实英文错拼（`wrld`、`recieve`、`teh`）仍然会被标红。
- `spelloptions = "camel"`：`CamelCase` 拆成多个单词检查，技术文档误报更少。

> 如果连这些设置和词表都不想要：删掉 `options.lua` 里"拼写检查(spell)"那一段和整个 `spell/` 目录即可
> （`<leader>us` 会随之失效）。

| 键 / 命令 | 作用 |
|---|---|
| `<leader>us` | 开关当前窗口的拼写检查 |
| `]s` / `[s` | 下一个 / 上一个拼写错误（原生） |
| `z=` | 对当前单词给出修改建议（原生） |
| `zg` / `zw` | 把当前词加进词表 / 标记为错误（原生） |
| `zG` / `zW` | 只在当前文件里忽略 / 标记（原生） |

词表文件（`stdpath("config")/spell/`）：

| 文件 | 说明 |
|---|---|
| `tech.en.utf-8.add` | 自定义词表，一个词一行，可以直接编辑 |
| `tech.en.utf-8.add.spl` | 编译产物，**必须存在词表才会在启动时生效** |

改了 `.add` 之后要重新编译（实测：只改 `.add` 不编译是不生效的）：

```vim
:mkspell! ~/.config/nvim/spell/tech.en.utf-8.add
```

> 两个实测踩过的坑：
> 1. `'spellfile'` 的文件名必须形如 `*.{encoding}.add`——写成 `tech.en-utf-8.add`（破折号）完全不生效；
> 2. 不能直接叫 `en.utf-8.add`：它的编译产物 `en.utf-8.spl` 会盖掉 nvim 自带的英文词典（所以加了 `tech.` 前缀）。

**关于"完整检查中文拼写"**：nvim 内置拼写没有中文词库（`spelllang` 里并不存在 `zh`），所以中文只能做到"不检查"，查不了错别字。真要校对中文，可选方案：

| 方案 | 能查什么 | 代价 |
|---|---|---|
| `ltex-ls-plus`（LanguageTool） | 中文标点/语法/中英混排（zh-CN 规则集有限） | 需要 Java（当前机器上没有），下载量 200MB+ |
| `textlint` + 中文技术写作规则 | 中英混排空格、全半角标点、常见错别字 | 需要 node（已有）+ 项目级 npm 配置，可挂到 efm-langserver |
| `cspell` / `harper-ls` | 只支持英文与代码拼写 | 不解决中文 |

需要用哪种说一声，只加对应那一个。

---

## 2. leader 分组总览（which-key）

| 前缀 | 分组 | 前缀 | 分组 |
|---|---|---|---|
| `<leader>b` | buffer | `<leader>M` | markdown |
| `<leader>f` | find/file | `<leader>s` | session |
| `<leader>g` | git | `<leader>u` | ui/toggle |
| `<leader>l` | lsp | `<leader>x` | diagnostics/quickfix |
| `<leader>m` | make | `<C-x>` | emacs prefix |
| `[` / `]` | prev / next | `g` / `z` | goto / fold |

按 `<leader>` 稍等即可看到分组面板；`<leader>fk` 可以搜索所有键位。

---

## 3. snacks.nvim

### 3.1 打开 picker

| 键 | 作用 |
|---|---|
| `<C-x><C-f>` / `<leader>ff` | 找文件 |
| `<leader>fg` | 全文搜索（grep，需要 rg） |
| `<leader>fw` | 搜索光标下的单词 |
| `<leader>fl` | **只在当前文件里搜索**（看 log/长文本很有用） |
| `<leader>fb` / `<leader>fr` / `<leader>fs` | buffer / 最近文件 / 智能查找 |
| `<leader>fh` / `<leader>fk` / `<leader>fc` | 帮助 / 键位 / 命令 |
| `<leader>fd` / `<leader>fq` | 诊断列表 / quickfix 列表 |
| `<leader>gs` / `<leader>gl` / `<leader>gL` | git status / log / 当前文件的 log |
| `<leader>gB` | 在浏览器打开当前文件（非 git 目录会提示而不是报错） |
| `<C-x>b` / `M-x` | 切换 buffer / 命令面板 |

### 3.2 picker 内部键位（snacks 默认，输入框与结果列表通用）

| 键 | 作用 | 键 | 作用 |
|---|---|---|---|
| `<CR>` | 打开选中项 | `<S-CR>` | 先选一个窗口，再在那里打开 |
| `<Esc>` / `q` / `<C-c>` | 关闭 | `<Tab>` / `<S-Tab>` | 下一个/上一个并多选 |
| `<C-j>` `<C-k>` / `<C-n>` `<C-p>` / `j` `k` | 列表上下移动 | `<C-a>` | 全选 |
| `<C-d>` / `<C-u>` | 列表翻半页 | `<C-f>` / `<C-b>` | 预览翻页 |
| `gg` / `G` | 列表首 / 列表尾 | `zt` `zz` `zb` | 结果列表滚到 顶/中/底 |
| `/` | 输入框 ↔ 结果列表切换焦点 | `i` | （结果列表）回到输入框 |
| `?` | 显示当前 picker 的帮助 | `<a-d>` | 调试：查看当前项数据 |
| `<a-f>` | 切换 follow | `<a-h>` / `<a-i>` | 切换隐藏文件 / gitignore 文件 |
| `<a-r>` | 切换正则（仅输入框） | `<a-m>` / `<a-p>` | 最大化 / 开关预览 |
| `<a-w>` | 在输入/列表/预览窗口间循环 | `<C-g>` | 输入框切 live；列表打印路径 |
| `<C-s>` / `<C-v>` / `<C-t>` | 分屏 / 垂直分屏 / 新标签页打开 | `<C-q>` | 结果送入 quickfix |
| `<C-w>H/J/K/L` | 把 picker 布局改成 左/下/上/右 | | |
| `<C-r><C-w>` | 插入光标下的单词 | `<C-r>%` / `<C-r>#` | 插入文件名 / 备用文件名 |
| `<C-r><C-l>` / `<C-r><C-f>` | 插入当前行 / 光标下文件名 | | |

### 3.3 其它

| 键 | 作用 |
|---|---|
| `<F5>` | 开关终端（普通模式和终端模式都可用） |
| `<leader>bd` / `<leader>bo` | 关闭当前 buffer / 关闭其它 buffer（保持窗口布局） |
| `<leader>un` | 通知历史 |
| `<leader>uz` / `<leader>uZ` | zen 模式 / zoom 模式 |

> 配置要点：`explorer` 关闭（文件树用 oil）；`statuscolumn` 只保留折叠列（没有装 gitsigns，所以不显示 git 标记）；`indent` 已开启，但在 diffview/diff 缓冲区里会自动关闭（规避上游 "Invalid window id" 的问题）。

---

## 4. 插入模式：blink.cmp + nvim-autopairs

分工：**括号由 nvim-autopairs 负责，blink 的自动括号已关闭**（`completion.accept.auto_brackets.enabled = false`），所以接受函数补全不会出现重复的 `()`。

| 键 | 来源 | 作用 |
|---|---|---|
| `<Tab>` | blink | 有候选就接受；片段激活时跳下一个占位符；否则是普通 Tab |
| `<S-Tab>` | blink | 片段上一个占位符 |
| `<C-space>` | blink | 打开补全菜单 / 打开文档 / 关闭文档 |
| `<C-e>` | blink | 取消补全 |
| `<C-n>` `<C-p>` / `<Up>` `<Down>` | blink | 下一个 / 上一个候选 |
| `<C-b>` `<C-f>` | blink | 文档上滚 / 下滚 |
| `<C-k>` | blink | 显示 / 隐藏函数签名 |
| `<CR>` | autopairs | 在括号中换行时自动补全缩进与闭合（blink 没有映射 `<CR>`，不冲突） |
| `<BS>` | autopairs | 删除左括号时同时删除右括号 |
| `(` `)` `[` `]` `{` `}` `'` `"` 反引号 | autopairs | 自动配对 |
| `<M-e>` | autopairs | fast_wrap（默认关闭，需要 `fast_wrap = {}` 才启用） |

命令行模式使用 blink 的 `super-tab` 预设，且 `auto_show = true`（输入 `:` 就会弹候选）。

---

## 5. LSP

原生 `grn` `gra` `grr` `gri` `grt` `grx` `gO` `K` `i_<C-S>` `]d` `[d` 已经够用（见 `keymaps-native.md` §1.2），本配置只补：

| 键 | 作用域 | 作用 |
|---|---|---|
| `gd` | 仅 LSP 挂载的 buffer | 跳转到定义 |
| `<leader>lc` | 仅 clangd 挂载的 buffer | 在源文件生成函数定义 |
| `<leader>li` | 全局 | 开关内联提示（inlay hints） |

### 各语言对应的 server（mason 自动安装）

| 语言/文件类型 | server | 说明 |
|---|---|---|
| C / C++ / CUDA / objc | `clangd` | 用系统 `/usr/bin/clangd`，不走 mason |
| python | `ruff` + `ty` | lint/format + 类型检查 |
| bash / sh / zsh | `bashls` | 装了 shellcheck 会自动做诊断 |
| lua | `lua_ls` | |
| cmake | `neocmake` | C/C++ 项目常用 |
| json / jsonc | `jsonls` | |
| yaml / toml | `yamlls` / `taplo` | |
| **HTML** | `html` | 同时给 `<style>`/`<script>` 内的 CSS/JS 提供补全 |
| **CSS / SCSS / LESS** | `cssls` | 已忽略未知 `@rule`（Tailwind 之类不会报错） |
| **JS / TS / JSX / TSX** | `ts_ls` | mason 会一并安装 typescript；有 tsconfig/jsconfig 就用项目配置 |
| **HTML/CSS 简写** | `emmet_language_server` | 输入 `div.box>ul>li*3` 后按补全键展开（blink 的 `<C-space>` 或 `<Tab>`） |

排查：`:checkhealth vim.lsp`。

---

## 6. trouble.nvim（诊断 / quickfix / 符号）

| 键 | 作用 |
|---|---|
| `<leader>xx` | 全部诊断 |
| `<leader>xX` | 当前 buffer 的诊断 |
| `<leader>xq` | quickfix 列表（`<leader>mm` 编译后的错误在这里） |
| `<leader>xl` | location list |
| `<leader>xs` | 文件符号（函数/结构体列表） |
| `<leader>xr` | LSP 定义/引用（右侧打开） |

trouble 窗口内自带键位（官方默认，buffer-local）：

| 键 | 作用 | 键 | 作用 |
|---|---|---|---|
| `<CR>` / `o` | 跳转 / 跳转并关闭 | `<C-s>` / `<C-v>` | 分屏 / 垂直分屏打开 |
| `}` `]]` / `{` `[[` | 下一个 / 上一个 | `q` / `<Esc>` | 关闭 |
| `p` / `P` | 预览 / 开关预览 | `i` | 查看详情 |
| `dd` | 删除当前项 | `gb` | 只看当前 buffer |
| `s` | 按严重级别过滤 | `?` | 帮助 |
| `zo` `zc` `za` `zR` `zM` | 折叠相关 | | |

---

## 7. diffview.nvim（git diff / 历史）

| 键 | 作用 |
|---|---|
| `<leader>gd` | 打开 diff（工作区 vs 索引） |
| `<leader>gD` | 当前文件的提交历史 |
| `<leader>gH` | 整个仓库的提交历史 |
| `<leader>gq` | 关闭 diffview |

常用命令：

```
:DiffviewOpen HEAD~2              和某次提交比较
:DiffviewOpen origin/main...HEAD
:DiffviewOpen -- src/             只看某个目录
:DiffviewFileHistory %            当前文件历史
:DiffviewFileHistory --range=origin..HEAD
:DiffviewLog                      出问题时看日志
```

diffview 窗口/面板内自带键位（官方默认，buffer-local）：

| 键 | 作用 | 键 | 作用 |
|---|---|---|---|
| `<tab>` / `<s-tab>` | 下一个 / 上一个文件 | `<leader>e` / `<leader>b` | 聚焦 / 开关文件面板 |
| `-` 或 `s` | **暂存当前 hunk** | `S` / `U` | 全部暂存 / 全部取消暂存 |
| `X` | 还原该文件 | `g<C-x>` | 切换布局 |
| `g?` | 帮助面板 | `g!` | （历史面板）选项 |

> 冲突解决（merge 时）：`<leader>co` / `ct` / `cb` 选 ours/theirs/base，`dx` 删除冲突区。
> 注意：diffview 的窗口里 `<leader>e` 是"聚焦文件面板"（buffer-local），不会触发 oil。

---

## 8. oil.nvim（文件管理器）

| 键 | 作用 |
|---|---|
| `-` | 打开**当前文件所在目录**；在 oil 里再按 `-` 回到上级 |
| `<leader>e` | 同上（文件管理器） |

其它打开方式：`:Oil <dir>` 打开指定目录、`:Oil --float` 浮动打开、`:Oil --trash /` 查看回收站。

oil buffer 内自带键位（官方默认，buffer-local）：

| 键 | 作用 | 键 | 作用 |
|---|---|---|---|
| `<CR>` | 打开文件/目录 | `<C-s>` / `<C-h>` / `<C-t>` | 垂直分屏 / 水平分屏 / 新标签页 |
| `-` | 回到上级 | `_` | 打开当前工作目录 |
| 反引号 | 把 cwd 切到该目录 | `g~` | 只切当前标签页的 cwd |
| `<C-p>` | 预览 | `<C-l>` | 刷新 |
| `<C-c>` | 关闭 | `g?` | 帮助 |
| `g.` | 显示/隐藏隐藏文件 | `gs` | 切换排序 |
| `gx` | 用外部程序打开 | `g\` | 回收站 |

**编辑方式**：像编辑普通文本一样改文件名、新建、删除、移动，然后 `:w` 才真正执行；`<CR>` 打开新/改名的文件时会提示先保存。

---

## 9. markview.nvim（markdown 渲染）

| 键 | 作用 |
|---|---|
| `<leader>Mm` | 开关渲染 |
| `<leader>Mh` | 混合模式（光标所在行显示源码） |
| `<leader>Mp` | 分屏预览 |

- markdown buffer 里 `gx` 被改成 `:Markview open`（打开链接，buffer-local）。想保留原生 `gx` 就在配置里加 `preview = { map_gx = false }`。
- `conceallevel` 由 markview 自己管理，所以 `options.lua` 里没有给 markdown 另设它。
- 其它命令：`:Markview Enable/Disable/Toggle`（全局）、`:Markview enable/disable/toggle`（当前 buffer）、`:Markview linewiseToggle`、`:Markview splitClose`。
- 只有执行 `:Markview traceExport` 时才会在当前目录写一个 `markview_log.txt`；日常渲染不会产生任何文件。

---

## 10. auto-session（会话）

| 键 | 作用 |
|---|---|
| `<leader>ss` | 保存当前 session |
| `<leader>sr` | 恢复 session |
| `<leader>sd` | 删除当前目录的 session |
| `<leader>sS` | 搜索并切换 session（用 snacks picker） |
| `<leader>sp` | 清理孤立的 session 文件 |

- 默认 `auto_save = true` / `auto_restore = true`：退出时自动保存，进入同一目录时自动恢复。
- session 文件位置：`~/.local/state/nvim/sessions/<按 %XX 编码的路径>.vim`（配置里从默认的 data 目录改到了 state 目录）。
- `suppressed_dirs` 已设置：`~/`、`~/Downloads`、`~/Documents`、`/`、`/tmp`、`/tmp/**` 不生成 session。
- `bypass_save_filetypes`：只有启动面板/文件管理器打开时不保存（避免产生无意义的 session）。
- `purge_after_minutes = 43200`：30 天没访问的 session 自动清理。
- 相关：`options.lua` 里按官方推荐设置了 `sessionoptions`，否则恢复后 filetype/高亮会错乱。

---

## 11. lualine（状态栏，无键位）

显示内容：模式 | 分支 · diff · 诊断 | 文件相对路径 | 文件类型 | 进度 | 行列。
`theme = "auto"` 会跟随 colorscheme（catppuccin 自带对应的 lualine 主题）。
`diff` 组件需要 gitsigns 之类的插件才有内容（本方案没装，所以为空，不影响使用）。
`:LualineNotices` 可以查看 lualine 的提示信息。

---

## 12. 常用命令速查

| 命令 | 来源 | 作用 |
|---|---|---|
| `<localleader>l` / `:Lazy` | lazy.nvim | 插件管理（`S` 同步、`U` 更新、`C` 检查、`X` 清理无用插件目录） |
| `<localleader>h` / `:checkhealth` | nvim | 健康检查（`vim.lsp` / `nvim-treesitter` / `snacks` / `auto-session` 等） |
| `:Mason` | mason | 图形化安装 LSP / 工具 |
| `:MasonInstall <pkg>` / `:MasonLog` | mason | 安装 / 查看日志 |
| `:AutoSession save/restore/delete/toggle/purgeOrphaned/search` | auto-session | 会话操作 |
| `:Trouble [mode] toggle` | trouble | 例如 `:Trouble diagnostics toggle`、`:Trouble lsp toggle win.position=right` |
| `:Oil <dir>` / `:Oil --float` | oil | 打开目录 |
| `:Markview` / `:Markview splitToggle` / `:Markview traceExport` | markview | 渲染控制（traceExport 会在当前目录写 `markview_log.txt`） |
| `:TSInstall` / `:TSUpdate` / `:TSLog` | nvim-treesitter | parser 管理（需要 `tree-sitter-cli`） |
| `:TSContext toggle` | treesitter-context | 开关顶部上下文条 |
| `:NvimWebDeviconsHiTest` | nvim-web-devicons | 预览所有图标（setup 之后可用） |

---

## 13. 自己排查键位

| 做法 | 说明 |
|---|---|
| `<leader>fk` | snacks 的键位搜索器（按名字/描述过滤，最直观） |
| `:verbose nmap <Space>ff` | 查看某个键被谁映射、定义在哪个文件哪一行 |
| `:nmap <C-v><C-x>` | 列出 `C-x` 前缀下的所有映射 |
| `:map` / `:nmap` / `:vmap` / `:imap` / `:map!` | 列出各模式全部映射 |
| `:Lazy` → `keys` 列 | 查看哪些键触发了插件的懒加载 |

加新键位时的两条原则（本配置遵循）：

1. **插件键位写在对应插件文件里**：全局用 lazy 的 `keys = {...}`，跟 buffer 相关的用 `on_attach` / `LspAttach` / `FileType`。
2. **不要占用原生默认键**，nvim 0.12 尤其注意：`g` 系（`grn gra grr gri grt grx gO gc gx`）、`]`/`[` 系（`]d [d ]q [q ]l [l ]a [a ]t [t ]b [b ]n [n ]<Space>`）、`<C-w>` 系、`K`、`Y`、`&`。

本方案有意覆盖的原生键只有这几个（详见 `keymaps-native.md` §8）：
`<C-x>`（变成前缀）、`<C-g>`、`n/v/o <C-j>` `<C-k>`、`v >` `<`、`-`（oil）、`i <CR>`（autopairs）、`<F5>`。
