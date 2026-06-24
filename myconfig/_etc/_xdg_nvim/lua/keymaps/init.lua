-- local function load_keymaps()
local files = vim.fn.glob(vim.fn.stdpath('config') .. '/lua/keymaps/*.lua', false, true)
for _, file in ipairs(files) do
    if not file:match('init%.lua$') then
        local module = file:match('([^/]+)%.lua$')
        if module then
        require('keymaps.' .. module)
        end
    end
end
-- end

-- load_keymaps()
