---@class SeekerPicker
local M = {}

local state = require('seeker.state')
local utils = require('seeker.utils')
local config_module = require('seeker.config')

---Toggle from file mode to grep mode
---@param picker table Snacks picker object
local function toggle_to_grep(picker)
    local items = utils.get_picker_items(picker)

    if #items == 0 then
        return
    end

    local file_paths = utils.extract_file_paths(items)

    if #file_paths == 0 then
        return
    end

    state.set_files(file_paths)
    state.set_mode('grep')

    picker:close()

    vim.schedule(function()
        M.create_grep_picker()
    end)
end

---Toggle from grep mode to file mode
---@param picker table Snacks picker object
local function toggle_to_file(picker)
    local items = utils.get_picker_items(picker)

    if #items == 0 then
        return
    end

    local file_paths = utils.get_unique_files(items)

    if #file_paths == 0 then
        return
    end

    state.set_grep_results(file_paths)
    state.set_mode('file')

    picker:close()

    vim.schedule(function()
        M.create_file_picker()
    end)
end

---Create a file picker
---If state has grep results, show filtered file list
---Otherwise show all files (git_files or files based on config)
M.create_file_picker = function()
    local config = config_module.get()
    local grep_files = state.get_grep_results()

    local picker_opts = vim.tbl_deep_extend('force', config.picker_opts or {}, {})

    picker_opts.actions = picker_opts.actions or {}
    picker_opts.actions.seeker_toggle = function(picker)
        toggle_to_grep(picker)
    end

    picker_opts.win = picker_opts.win or {}
    picker_opts.win.input = picker_opts.win.input or {}
    picker_opts.win.input.keys = picker_opts.win.input.keys or {}

    picker_opts.win.input.keys[config.toggle_key] = {
        'seeker_toggle',
        mode = { 'n', 'i' },
        desc = 'Seeker: Toggle to grep mode',
    }

    if #grep_files > 0 then
        local Snacks = require('snacks')
        local cwd = vim.fn.getcwd()

        picker_opts.finder = function()
            local items = {}
            for _, file in ipairs(grep_files) do
                local relative_path = vim.fn.fnamemodify(file, ':~:.')
                table.insert(items, {
                    text = relative_path,
                    file = relative_path,
                    cwd = cwd,
                })
            end
            return items
        end

        Snacks.picker.pick('files', picker_opts)
    else
        local Snacks = require('snacks')
        if config.picker_type == 'git_files' then
            Snacks.picker.git_files(picker_opts)
        else
            Snacks.picker.files(picker_opts)
        end
    end
end

---Create a grep picker
---Uses file list from state if available
M.create_grep_picker = function()
    local config = config_module.get()
    local file_list = state.get_files()

    local picker_opts = vim.tbl_deep_extend('force', config.picker_opts or {}, {})

    picker_opts.actions = picker_opts.actions or {}
    picker_opts.actions.seeker_toggle = function(picker)
        toggle_to_file(picker)
    end

    picker_opts.win = picker_opts.win or {}
    picker_opts.win.input = picker_opts.win.input or {}
    picker_opts.win.input.keys = picker_opts.win.input.keys or {}

    picker_opts.win.input.keys[config.toggle_key] = {
        'seeker_toggle',
        mode = { 'n', 'i' },
        desc = 'Seeker: Toggle to file mode',
    }

    if #file_list > 0 then
        local relative_paths = {}
        for _, file in ipairs(file_list) do
            table.insert(relative_paths, vim.fn.fnamemodify(file, ':~:.'))
        end
        picker_opts.glob = relative_paths
    end

    local Snacks = require('snacks')
    Snacks.picker.grep(picker_opts)
end

---Main entry point for seeker
---@param opts table? Optional configuration
M.seek = function(opts)
    state.init()

    if opts then
        config_module.setup(opts)
    end

    M.create_file_picker()
end

return M
