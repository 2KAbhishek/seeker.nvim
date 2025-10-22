local config = require('seeker.config').config

---@class SeekerCommands
local M = {}

---Add default keymaps for commands
local function add_default_keymaps()
    local function add_keymap(keys, cmd, desc)
        vim.api.nvim_set_keymap('n', keys, cmd, { noremap = true, silent = true, desc = desc })
    end

    add_keymap('<leader>ff', ':Seeker<CR>', 'Seek Files')
end

---Main command handler
---@param opts table
local function seeker_command(opts)
    require('seeker.picker').seek()
end

---Setup function to initialize commands
M.setup = function()
    vim.api.nvim_create_user_command('Seeker', seeker_command, {
        nargs = 0,
        desc = 'Start Seeker file investigation',
    })

    if config.add_default_keybindings then
        add_default_keymaps()
    end
end

return M
