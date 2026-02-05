---@class SeekerBackendSnacks
local M = {}

local state = require('seeker.state')
local utils = require('seeker.utils')
local config_module = require('seeker.config')
local Snacks = require('snacks')

---Toggle from file mode to grep mode
---@param picker table Snacks picker object
---@param custom_picker_opts table Picker options to override defaults
local function toggle_to_grep(picker, custom_picker_opts)
    local items = utils.get_picker_items(picker)

    if #items == 0 then
        return
    end

    local file_paths = {}
    for _, item in ipairs(items) do
        local file
        if type(item) == 'string' then
            file = item
        elseif type(item) == 'table' then
            file = item.file or item.path or item.filename
        end

        if file then
            local cwd = (type(item) == 'table' and item.cwd) or vim.fn.getcwd()
            local abs_path = vim.fn.fnamemodify(vim.fs.joinpath(cwd, file), ':p')
            table.insert(file_paths, abs_path)
        end
    end

    if #file_paths == 0 then
        return
    end

    state.set_files(file_paths)
    state.set_mode('grep')

    picker:close()

    vim.schedule(function()
        M.create_grep_picker(custom_picker_opts)
    end)
end

---Toggle from grep mode to file mode
---@param picker table Snacks picker object
---@param custom_picker_opts table Picker options to verride defaults
local function toggle_to_file(picker, custom_picker_opts)
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
        M.create_file_picker(custom_picker_opts)
    end)
end

---Create a file picker
---@param custom_picker_opts table Picker options to override defaults
---@param mode string? 'git_files' or 'files' (auto-detect if nil)
M.create_file_picker = function(custom_picker_opts, mode)
    local config = config_module.get()
    local grep_files = state.get_grep_results()

    local picker_opts = vim.tbl_deep_extend('force', config.picker_opts or {}, {})
    picker_opts = vim.tbl_deep_extend('force', picker_opts, custom_picker_opts or {})

    picker_opts.actions = picker_opts.actions or {}
    picker_opts.actions.seeker_toggle = function(picker)
        toggle_to_grep(picker, custom_picker_opts)
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
        if not mode then
            mode = utils.is_git_repo() and 'git_files' or 'files'
        end

        if mode == 'git_files' then
            Snacks.picker.git_files(picker_opts)
        else
            Snacks.picker.files(picker_opts)
        end
    end
end

---Create a grep picker
---@param custom_picker_opts table Picker options to override defaults
M.create_grep_picker = function(custom_picker_opts)
    local config = config_module.get()
    local file_list = state.get_files()

    local picker_opts = vim.tbl_deep_extend('force', config.picker_opts or {}, {})
    picker_opts = vim.tbl_deep_extend('force', picker_opts, custom_picker_opts or {})

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
        picker_opts.dirs = file_list
    end

    Snacks.picker.grep(picker_opts)
end

return M
