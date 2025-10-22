local template_module = require('template.module')
local config = require('template.config').config

---@class TemplateCommands
local M = {}

---Add default keymaps for commands
local function add_default_keymaps()
    local function add_keymap(keys, cmd, desc)
        vim.api.nvim_set_keymap('n', keys, cmd, { noremap = true, silent = true, desc = desc })
    end

    add_keymap('<leader>th', ':Template greet<CR>', 'Template greet default')
    add_keymap('<leader>tH', ':Template greet Neovim<CR>', 'Template greet Neovim')
end

---Simple completion function for the main command
---@param arg_lead string
---@param cmd_line string
---@return string[]
local function get_completions(arg_lead, cmd_line)
    local args = vim.split(vim.trim(cmd_line), '%s+')

    -- Remove command name
    if args[1] == 'Template' then
        table.remove(args, 1)
    end

    -- Complete subcommands
    if #args == 0 or (#args == 1 and not cmd_line:match('%s$')) then
        local subcommands = { 'greet', 'notify' }
        local matches = {}

        for _, cmd in ipairs(subcommands) do
            if cmd:find('^' .. vim.pesc(arg_lead or ''), 1, false) then
                table.insert(matches, cmd)
            end
        end

        return matches
    end

    -- Complete names for 'greet' subcommand
    if args[1] == 'greet' and (#args == 1 or (#args == 2 and not cmd_line:match('%s$'))) then
        local names = { 'World', 'Neovim', 'Vim', 'Lua', 'Developer', 'Coder' }
        local matches = {}

        for _, name in ipairs(names) do
            if name:find('^' .. vim.pesc(arg_lead or ''), 1, false) then
                table.insert(matches, name)
            end
        end

        return matches
    end

    return {}
end

---Main command handler
---@param opts table
local function template_command(opts)
    local args = vim.split(opts.args, '%s+')
    local subcommand = args[1]

    if not subcommand or subcommand == '' then
        vim.notify('Usage: Template <greet|notify> [args]', vim.log.levels.INFO)
        return
    end

    if subcommand == 'greet' then
        template_module.greet(args[2])
    elseif subcommand == 'notify' then
        local message = table.concat(args, ' ', 2)
        template_module.show_notification(message)
    else
        vim.notify('Unknown subcommand: ' .. subcommand .. '\nAvailable: greet, notify', vim.log.levels.ERROR)
    end
end

---Setup function to initialize commands
M.setup = function()
    vim.api.nvim_create_user_command('Template', template_command, {
        nargs = '*',
        complete = get_completions,
        desc = 'Template plugin commands',
    })

    if config.add_default_keybindings then
        add_default_keymaps()
    end
end

return M
