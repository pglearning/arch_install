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
keymap({ "n", "v", "o" }, "<leader>nh", ":nohl<CR>", { desc = "No highlight" })
-- File control
keymap({ "n", "v", "o", "i" }, "<C-s>", ":w<CR>", { desc = "Save file" })
keymap({ "n", "v", "o" }, "<leader>n", ":new ", { desc = "Enter filename to create/open file in new window" })
keymap({ "n", "v", "o" }, "<leader>e", ":tabnew ", { desc = "Enter filename to create/open file in a new tab" })
-- Window
keymap({ "n", "v", "o" }, "sv", "<C-w>v", { desc = "Create window vertical" })
keymap({ "n", "v", "o" }, "sh", "<C-w>s", { desc = "Create window horizontal" })
keymap({ "n", "v", "o" }, "sc", "<C-w>c", { desc = "Close current window" })
keymap({ "n", "v", "o" }, "so", "<C-w>o", { desc = "Close other window" })
keymap({ "n", "v", "o" }, "<C-h>", "<C-w>h", { desc = "Switch window left" })
keymap({ "n", "v", "o" }, "<C-l>", "<C-w>l", { desc = "Switch window right" })
keymap({ "n", "v", "o" }, "<C-j>", "<C-w>j", { desc = "Switch window down" })
keymap({ "n", "v", "o" }, "<C-k>", "<C-w>k", { desc = "Switch window up" })
-- File buffer
keymap({ "n", "v", "o" }, "<leader>b", "<cmd>ls<CR>", { desc = "List all file buffer"})
keymap({ "n", "v", "o" }, "<leader>bn", "<cmd>bn<CR>", { desc = "Switch to next file buffer" })
keymap({ "n", "v", "o" }, "<leader>bp", "<cmd>bp<CR>", { desc = "Switch to previous file buffer" })
-- File Tab
keymap({ "n", "v", "o" }, "<leader>t", ":tabs<CR>", { desc = "List all open tab" })
keymap({ "n", "v", "o" }, "<leader>te", ":tabnew<CR>", { desc = "Create a new empty tab" })
keymap({ "n", "v", "o" }, "<leader>tc", ":tabclose<CR>", { desc = "Close current tab" })
keymap({ "n", "v", "o" }, "<leader>tco", ":tabonly<CR>", { desc = "Close other tab" })
keymap({ "n", "v", "o" }, "<leader>tn", ":tabnext<CR>", { desc = "Switch to next tab" })
keymap({ "n", "v", "o" }, "<leader>tp", ":tabprevious<CR>", { desc = "Switch to previous tab" })
keymap({ "n", "v", "o" }, "<leader>tm0", ":tabmove 0<CR>", { desc = "Move current tab to begin" })
keymap({ "n", "v", "o" }, "<leader>tm", ":tabmove<CR>", { desc = "Move current tab to end" })
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
