
local keymap = vim.keymap.set
keymap({ "n", "v", "o" }, "<leader>ff", function()
    require("snacks").picker.files()
end, { desc = "Find files" })

keymap("n", "<leader>fg", function()
    require("snacks").picker.grep()
end, { desc = "Grep files" })

keymap("n", "<leader>fb", function()
    require("snacks").picker.buffers()
end, { desc = "Buffers" })

keymap("n", "<leader>fr", function()
    require("snacks").picker.recent()
end, { desc = "Recent files" })

keymap("n", "<leader>fs", function()
    require("snacks").picker.smart()
end, { desc = "Smart find" })
