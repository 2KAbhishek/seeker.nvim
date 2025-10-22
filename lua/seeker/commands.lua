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

---Completion function for Seeker command
---@param arg_lead string
---@param cmd_line string
---@param cursor_pos number
---@return string[]
local function seeker_complete(arg_lead, cmd_line, cursor_pos)
    local modes = { 'files', 'git_files', 'grep' }
    local matches = {}

    for _, mode in ipairs(modes) do
        if mode:find('^' .. vim.pesc(arg_lead)) then
            table.insert(matches, mode)
        end
    end

    return matches
end

---Main command handler
---@param opts table
local function seeker_command(opts)
    local args = vim.split(vim.trim(opts.args or ''), '%s+')
    local mode = args[1]

    require('seeker.picker').seek({ mode = mode })
end

---Setup function to initialize commands
M.setup = function()
    vim.api.nvim_create_user_command('Seeker', seeker_command, {
        nargs = '?',
        complete = seeker_complete,
        desc = 'Seek Files (modes: files, git_files, grep)',
    })

    if config.add_default_keybindings then
        add_default_keymaps()
    end
end

return M
