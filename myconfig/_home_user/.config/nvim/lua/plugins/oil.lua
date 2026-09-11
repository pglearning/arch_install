return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,   -- 官方建议: oil 要接管目录 buffer(替代 netrw), 必须早点加载
    keys = {
        -- oil 官方推荐的映射: - 打开当前文件所在目录, 在里面再按 - 回到上级
        { "-", "<cmd>Oil<CR>", desc = "Oil: 打开当前文件所在目录" },
        { "<leader>e", "<cmd>Oil<CR>", desc = "Oil: 文件管理器(当前文件所在目录)" },
        -- 其它常用: :Oil <dir> 打开指定目录, :Oil --float 浮动打开,
        --           oil 里按 g? 查看全部键位
    },
    opts = {
        -- 官方选项与默认值(节选):
        --   default_file_explorer=true   接管目录 buffer
        --   columns={ "icon" }           可加 "permissions"/"size"/"mtime"
        --   delete_to_trash=false        需要 trash-cli, 系统里没有就不要开
        --   skip_confirm_for_simple_edits=false   简单改名/移动也要确认
        --   prompt_save_on_select_new_entry=true
        --   cleanup_delay_ms=2000        隐藏的 oil buffer 自动清理
        --   constrain_cursor="editable"  光标只能停在文件名上
        --   watch_for_changes=false      外部改动不会自动刷新(按 <C-l> 手动刷新)
        --   lsp_file_methods={ enabled=true, timeout_ms=1000, autosave_changes=false }
        --   use_default_keymaps=true
        --   view_options={ show_hidden=false, natural_order="fast", case_insensitive=false,
        --                  sort={ {"type","asc"}, {"name","asc"} } }
        --   float={...} preview_win={...} confirmation={...} progress={...}
        --
        -- oil buffer 内自带键位(官方默认, buffer-local, 不会影响别的窗口):
        --   <CR> 打开文件/目录   <C-s>/<C-h>/<C-t> 分屏/水平分屏/新标签打开
        --   -  回到上级目录      _  打开当前工作目录      `  切换 cwd 到该目录
        --   <C-p> 预览           <C-l> 刷新               <C-c> 关闭
        --   g. 显示/隐藏隐藏文件 gs  切换排序            g\  回收站
        --   g?  帮助
        -- 编辑方式: 像编辑普通文本一样改文件名/新建/删除, 然后 :w 保存生效
        view_options = {
            show_hidden = false,        -- 官方默认值
            natural_order = "fast",     -- 官方默认值
        },
    },
}
