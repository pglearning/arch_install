-- Functions --
local function wrap_visual_selection(quote)
    -- save register content
    local saved_reg = vim.fn.getreg('"')
    local saved_reg_type = vim.fn.getregtype('"')
    -- copy text to register
    vim.cmd('normal! y')
    local selected = vim.fn.getreg('"')
    -- add ' to text begin and end
    local wrapped = quote .. selected .. quote
    vim.fn.setreg('"', wrapped)
    -- paste and replace selected text
    vim.cmd('normal! gvp')
    -- recover register content    
    vim.fn.setreg('"', saved_reg, save_reg_type)
end

-- Keymaps Setting --
vim.g.mapleader = " "                   -- set leader space
vim.g.maplocalleader = "\\"
vim.g.snacks_animate = false            -- disable animation provided by snacks

local keymap = vim.keymap.set
-- Highlight
keymap({ "n", "v", "o" }, "<leader>nh", "<Esc>:nohl<CR>", { desc = "No highlight" })
keymap({ "n", "v", "o" }, "<leader>wq", "<Esc>:wq<CR>", { desc = "No highlight" })
-- File control
keymap({ "n", "v", "o" }, "<C-s>", "<Esc>:w<CR>", { desc = "Save file" })
keymap({ "n", "v", "o" }, "<leader>e", ":e ", { desc = "Enter filename to edit new file" })
-- Window
keymap({ "n", "v", "o" }, "<leader>n", ":vnew ", { desc = "Enter filename to create/open file in new window" })
keymap({ "n", "v", "o" }, "sv", "<C-w>v", { desc = "Create window vertical" })
keymap({ "n", "v", "o" }, "sh", "<C-w>s", { desc = "Create window horizontal" })
keymap({ "n", "v", "o" }, "sc", "<C-w>c", { desc = "Close current window" })
keymap({ "n", "v", "o" }, "so", "<C-w>o", { desc = "Close other window" })
keymap({ "n", "v", "o" }, "<leader>w", "<C-w>w", { desc = "Switch to beteen 2 window" })
keymap({ "n", "v", "o" }, "<C-h>", "<C-w>h", { desc = "Switch to window left" })
keymap({ "n", "v", "o" }, "<C-l>", "<C-w>l", { desc = "Switch to window right" })
keymap({ "n", "v", "o" }, "<C-j>", "<C-w>j", { desc = "Switch to window down" })
keymap({ "n", "v", "o" }, "<C-k>", "<C-w>k", { desc = "Switch to window up" })
keymap({ "n", "v", "o" }, "<leader>f", "<C-w>_<C-w>|", { desc = "Max current window" })
keymap({ "n", "v", "o" }, "<C-H>", "<C-w>H", { desc = "move window to left" })
keymap({ "n", "v", "o" }, "<C-L>", "<C-w>L", { desc = "move window to right" })
keymap({ "n", "v", "o" }, "<C-J>", "<C-w>J", { desc = "move window to down" })
keymap({ "n", "v", "o" }, "<C-K>", "<C-w>K", { desc = "move window to up" })
keymap({ "n", "v", "o" }, "<leader>=", "<C-w>=", { desc = "average size of all windows" })
keymap({ "n", "v", "o" }, "<C-Up>", "<Esc>:resize +3<cr>", { desc = "Increase height" })
keymap({ "n", "v", "o" }, "<C-Down>", "<Esc>:resize -3<cr>", { desc = "Decrease height" })
keymap({ "n", "v", "o" }, "<C-Right>", "<Esc>:vertical resize -5<cr>", { desc = "Increase width" })
keymap({ "n", "v", "o" }, "<C-Left>", "<Esc>:vertical resize +5<cr>", { desc = "Decrease width" })
-- File buffer
-- keymap({ "n", "v", "o" }, "<leader>b", "<cmd>ls<CR>", { desc = "List all file buffer"})
-- keymap({ "n", "v", "o" }, "<leader>bn", "<cmd>bn<CR>", { desc = "Switch to next file buffer" })
-- keymap({ "n", "v", "o" }, "<leader>bp", "<cmd>bp<CR>", { desc = "Switch to previous file buffer" })
-- File Tab
keymap({ "n", "v", "o" }, "<leader>t", "<Esc>:tabs<CR>", { desc = "List all open tab" })
keymap({ "n", "v", "o" }, "<leader>te", "<Esc>:tabnew<CR>", { desc = "Create a new empty tab" })
keymap({ "n", "v", "o" }, "<leader>tc", "<Esc>:tabclose<CR>", { desc = "Close current tab" })
keymap({ "n", "v", "o" }, "<leader>tco", "<Esc>:tabonly<CR>", { desc = "Close other tab" })
keymap({ "n", "v", "o" }, "<leader>tn", "<Esc>:tabnext<CR>", { desc = "Switch to next tab" })
keymap({ "n", "v", "o" }, "<leader>tp", "<Esc>:tabprevious<CR>", { desc = "Switch to previous tab" })
keymap({ "n", "v", "o" }, "<leader>tm0", "<Esc>:tabmove 0<CR>", { desc = "Move current tab to begin" })
keymap({ "n", "v", "o" }, "<leader>tm", "<Esc>:tabmove<CR>", { desc = "Move current tab to end" })
keymap({ "n", "v", "o" }, "<Tab>1", "1gt", { desc = "Switch to tab N" })
keymap({ "n", "v", "o" }, "<Tab>2", "2gt", { desc = "Switch to tab N" })
keymap({ "n", "v", "o" }, "<Tab>3", "3gt", { desc = "Switch to tab N" })
keymap({ "n", "v", "o" }, "<Tab>4", "4gt", { desc = "Switch to tab N" })
keymap({ "n", "v", "o" }, "<Tab>5", "5gt", { desc = "Switch to tab N" })
keymap({ "n", "v", "o" }, "<Tab>6", "6gt", { desc = "Switch to tab N" })
keymap({ "n", "v", "o" }, "<Tab>7", "7gt", { desc = "Switch to tab N" })
keymap({ "n", "v", "o" }, "<Tab>8", "8gt", { desc = "Switch to tab N" })
keymap({ "n", "v", "o" }, "<Tab>9", "9gt", { desc = "Switch to tab N" })
keymap({ "n", "v", "o" }, "<Tab>0", ":tablast<CR>", { desc = "Switch to last tab" })

-- Cursor
-- The 'W' uppercase word will not ignore symbol, 'w' ignore symbol
keymap( "i", "<C-h>", "<C-o>B", { desc = "Move to previous word begin" })
keymap( "i", "<C-l>", "<C-o>w", { desc = "Move to next word begin" })
keymap({ "n", "v", "o" }, "H", "B", { desc = "Move to previous word begin" })     -- Or use 'w' Move to next word begin
keymap({ "n", "v", "o" }, "L", "E", { desc = "Move to next word end" })
keymap({ "n", "v", "o" }, "J", "5j", { desc = "Move down 5 line" })
keymap({ "n", "v", "o" }, "K", "5k", { desc = "Move up 5 line" })

-- Edit

-- Move code
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected block code up" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected block code down" })
keymap("v", ">", ">gv", { desc = "Add tab for line" })
keymap("v", "<", "<gv", { desc = "Remove tab for line" })

-- Copy Paste
keymap( "v", "<C-S-v>", '"+p', { noremap = true, silent = true, desc = "Paste from clipboard" })
keymap( "v", "<C-S-c>", '"+yy', { noremap = true, silent = true, desc = "Copy a line to clipboard" })

-- Wrap quote
keymap("v", "'", function() wrap_visual_selection("'") end,
    { noremap = true, silent = true, desc = "Wrap with single quotes" })
keymap("v", '"', function() wrap_visual_selection('"') end,
    { noremap = true, silent = true, desc = "Wrap with double quotes" })
keymap("v", '`', function() wrap_visual_selection('`') end,
    { noremap = true, silent = true, desc = "Wrap with backtick" })
