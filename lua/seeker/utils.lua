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

---Get visual selection text
---@return string? Visual selection text or nil if not available
M.get_visual_selection = function()
    local mode = vim.fn.mode()
    local is_visual = mode:match('^[vV\22]') ~= nil

    local start_pos, end_pos
    if is_visual then
        start_pos = vim.fn.getpos('v')
        end_pos = vim.fn.getpos('.')
    else
        start_pos = vim.fn.getpos("'<")
        end_pos = vim.fn.getpos("'>")
    end

    local start_row, start_col = start_pos[2], start_pos[3]
    local end_row, end_col = end_pos[2], end_pos[3]

    if start_row == 0 or end_row == 0 then
        return nil
    end

    if start_row > end_row or (start_row == end_row and start_col > end_col) then
        start_row, end_row = end_row, start_row
        start_col, end_col = end_col, start_col
    end

    local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
    if #lines == 0 then
        return nil
    end

    if #lines == 1 then
        lines[1] = string.sub(lines[1], start_col, end_col)
    else
        lines[1] = string.sub(lines[1], start_col)
        lines[#lines] = string.sub(lines[#lines], 1, end_col)
    end

    local text = table.concat(lines, '\n')
    if text == '' then
        return nil
    end

    return text
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
