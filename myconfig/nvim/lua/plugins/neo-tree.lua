return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	lazy = false,
	opts = {
		close_if_last_window = false,
		window = {
			position = "left",
			width = 30,
		},
		filesystem = {
            follow_current_file = {
                enabled = true,
                leave_dirs_open = false
            },
			filtered_items = {
				visible = false,
				hide_dotfiles = false,
				hide_gitignored = false,
				hide_by_name = {
					-- ".git",
					-- ".DS_Store",
				},
				hide_by_pattern = {
					-- "*.pdf",
				},
			},
		},
	},
}
