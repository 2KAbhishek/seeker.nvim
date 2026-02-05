---@class SeekerBackendTelescope
local M = {}

local state = require('seeker.state')
local utils = require('seeker.utils')
local config_module = require('seeker.config')

---Extract all items from telescope picker (multi-select + all filtered)
---@param prompt_bufnr number Buffer number
---@param picker table Telescope picker object
---@return table[] Items
local function get_all_picker_items(prompt_bufnr, picker)
    local action_utils = require('telescope.actions.utils')

    local multi = picker:get_multi_selection()

    if #multi > 0 then
        return multi
    end

    local all_items = {}
    action_utils.map_entries(prompt_bufnr, function(entry)
        table.insert(all_items, entry)
    end)
    return all_items
end

---Extract file paths from telescope entries
---@param entries table[] Telescope entries
---@return string[] File paths
local function extract_file_paths(entries)
    if not entries or #entries == 0 then
        return {}
    end

    local paths = {}
    local seen = {}

    for _, entry in ipairs(entries) do
        local path = entry.path or entry.filename or entry.value

        if path and not seen[path] then
            table.insert(paths, path)
            seen[path] = true
        end
    end

    return paths
end

---Toggle from file mode to grep mode
---@param prompt_bufnr number Buffer number
---@param custom_picker_opts table Picker options to override defaults
local function toggle_to_grep(prompt_bufnr, custom_picker_opts)
    local action_state = require('telescope.actions.state')
    local actions = require('telescope.actions')

    local picker = action_state.get_current_picker(prompt_bufnr)
    local items = get_all_picker_items(prompt_bufnr, picker)

    if #items == 0 then
        return
    end

    local file_paths = extract_file_paths(items)

    if #file_paths == 0 then
        return
    end

    state.set_files(file_paths)
    state.set_mode('grep')

    actions.close(prompt_bufnr)

    vim.schedule(function()
        M.create_grep_picker(custom_picker_opts)
    end)
end

---Toggle from grep mode to file mode
---@param prompt_bufnr number Buffer number
---@param custom_picker_opts table Picker options to override defaults
local function toggle_to_file(prompt_bufnr, custom_picker_opts)
    local action_state = require('telescope.actions.state')
    local actions = require('telescope.actions')

    local picker = action_state.get_current_picker(prompt_bufnr)
    local items = get_all_picker_items(prompt_bufnr, picker)

    if #items == 0 then
        return
    end

    local file_paths = extract_file_paths(items)

    if #file_paths == 0 then
        return
    end

    state.set_grep_results(file_paths)
    state.set_mode('file')

    actions.close(prompt_bufnr)

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

    local opts = vim.tbl_deep_extend('force', config.picker_opts or {}, {})
    opts = vim.tbl_deep_extend('force', opts, custom_picker_opts or {})

    opts.attach_mappings = function(prompt_bufnr, map)
        map({ 'i', 'n' }, config.toggle_key, function()
            toggle_to_grep(prompt_bufnr, custom_picker_opts)
        end)
        return true
    end

    if #grep_files > 0 then
        local pickers = require('telescope.pickers')
        local finders = require('telescope.finders')
        local conf = require('telescope.config').values
        local make_entry = require('telescope.make_entry')

        opts.prompt_title = opts.prompt_title or 'Files (Filtered)'

        pickers
            .new(opts, {
                prompt_title = opts.prompt_title,
                finder = finders.new_table({
                    results = grep_files,
                    entry_maker = make_entry.gen_from_file(opts),
                }),
                sorter = conf.file_sorter(opts),
                previewer = conf.file_previewer(opts),
            })
            :find()
    else
        local builtin = require('telescope.builtin')

        if not mode then
            mode = utils.is_git_repo() and 'git_files' or 'files'
        end

        if mode == 'git_files' then
            builtin.git_files(opts)
        else
            builtin.find_files(opts)
        end
    end
end

---Create a grep picker
---@param custom_picker_opts table Picker options to override defaults
M.create_grep_picker = function(custom_picker_opts)
    local config = config_module.get()
    local file_list = state.get_files()
    local builtin = require('telescope.builtin')

    local opts = vim.tbl_deep_extend('force', config.picker_opts or {}, {})
    opts = vim.tbl_deep_extend('force', opts, custom_picker_opts or {})

    opts.attach_mappings = function(prompt_bufnr, map)
        map({ 'i', 'n' }, config.toggle_key, function()
            toggle_to_file(prompt_bufnr, custom_picker_opts)
        end)
        return true
    end

    if #file_list > 0 then
        opts.search_dirs = file_list
    end

    builtin.live_grep(opts)
end

return M
