---@class SeekerCommands
local M = {}

---Completion function for Seeker command
---@param arg_lead string
---@param cmd_line string
---@param cursor_pos number
---@return string[]
local function seeker_complete(arg_lead, cmd_line, cursor_pos)
    local modes = { 'files', 'git_files', 'grep', 'grep_word' }
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
    local picker_opts = {}

    if mode == 'grep_word' and opts.range ~= 0 then
        local visual_text = require('seeker.utils').get_visual_selection()
        if visual_text and visual_text ~= '' then
            picker_opts.search = visual_text
        end
    end

    require('seeker.picker').seek({ mode = mode, picker_opts = picker_opts })
end

---Setup function to initialize commands
M.setup = function()
    vim.api.nvim_create_user_command('Seeker', seeker_command, {
        nargs = '?',
        range = true,
        complete = seeker_complete,
        desc = 'Seek Files (modes: files, git_files, grep, grep_word)',
    })
end

return M
