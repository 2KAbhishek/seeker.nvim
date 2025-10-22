---@class SeekerUtils
local M = {}

---Check if current directory is a git repository
---@return boolean
M.is_git_repo = function()
    local git_dir = vim.fn.finddir('.git', vim.fn.getcwd() .. ';')
    return git_dir ~= ''
end

---Extract file paths from picker items
---Handles both file picker items (strings or tables with path/file fields)
---and grep picker items (tables with filename field)
---@param items table[] Picker items
---@return string[] File paths
M.extract_file_paths = function(items)
    if not items or #items == 0 then
        return {}
    end

    local paths = {}
    local seen = {}

    for _, item in ipairs(items) do
        local path = nil

        if type(item) == 'string' then
            path = item
        elseif type(item) == 'table' then
            path = item.file or item.path or item.filename
        end

        if path and not seen[path] then
            table.insert(paths, path)
            seen[path] = true
        end
    end

    return paths
end

---Extract unique file paths from grep results
---Grep items typically have a filename field
---@param grep_items table[] Grep picker items
---@return string[] Unique file paths
M.get_unique_files = function(grep_items)
    return M.extract_file_paths(grep_items)
end

---Normalize paths to absolute paths
---@param paths string[] File paths
---@param cwd string? Current working directory (defaults to vim.fn.getcwd())
---@return string[] Absolute paths
M.normalize_paths = function(paths, cwd)
    if not paths or #paths == 0 then
        return {}
    end

    cwd = cwd or vim.fn.getcwd()
    local normalized = {}

    for _, path in ipairs(paths) do
        local absolute_path
        if vim.fn.fnamemodify(path, ':p') == path then
            absolute_path = path
        else
            absolute_path = vim.fn.fnamemodify(cwd .. '/' .. path, ':p')
        end

        table.insert(normalized, absolute_path)
    end

    return normalized
end

---Validate that files exist
---@param paths string[] File paths
---@return string[] Valid file paths
---@return string[] Invalid file paths
M.validate_files = function(paths)
    if not paths or #paths == 0 then
        return {}, {}
    end

    local valid = {}
    local invalid = {}

    for _, path in ipairs(paths) do
        if vim.fn.filereadable(path) == 1 then
            table.insert(valid, path)
        else
            table.insert(invalid, path)
        end
    end

    return valid, invalid
end

---Convert paths to relative paths (relative to cwd)
---@param paths string[] Absolute or relative paths
---@param cwd string? Current working directory (defaults to vim.fn.getcwd())
---@return string[] Relative paths
M.to_relative_paths = function(paths, cwd)
    if not paths or #paths == 0 then
        return {}
    end

    cwd = cwd or vim.fn.getcwd()
    local relative = {}

    for _, path in ipairs(paths) do
        local rel_path = vim.fn.fnamemodify(path, ':~:.')
        table.insert(relative, rel_path)
    end

    return relative
end

---Get items from picker (selected or all filtered)
---@param picker table Snacks picker object
---@return table[] Items
M.get_picker_items = function(picker)
    if not picker then
        return {}
    end

    local selected = picker:selected()
    if selected and #selected > 0 then
        return selected
    end

    local items = picker:items()
    return items or {}
end

return M
