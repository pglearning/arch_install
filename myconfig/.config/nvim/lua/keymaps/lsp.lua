
local keymap = vim.keymap.set
-- definition include all next 3 function
keymap( {'n', 'v', 'o'}, 'gd', vim.lsp.buf.definition, { desc = "Go to definition" })
-- keymap( {'n', 'v', 'o'}, 'gD', vim.lsp.buf.declaration, { desc = "Go to declaration" })
-- keymap( {'n', 'v', 'o'}, 'gi', vim.lsp.buf.implementation, { desc = "Go to implementation" })
-- keymap( {'n', 'v', 'o'}, 'gt', vim.lsp.buf.type_definition, { desc = "Go to type_definition" })

keymap("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format" })

vim.keymap.set('n', '<leader>lc', function()
    vim.lsp.buf.code_action({
        filter = function(action)
            -- 只匹配 clangd 的生成定义动作
            return action.title:find("Generate definition") ~= nil
        end,
        apply = true,  -- 自动应用第一个匹配的动作
    })
end, { desc = "Generate C++ function definition via clangd" })
