---@class SeekerState
local M = {}

---@class StateData
---@field mode string Current mode ('file' | 'grep')
---@field file_list string[] File paths to search (for grep mode)
---@field grep_files string[] Files with grep matches (for file mode)
---@field history table[] Stack of refinements for potential undo

---@type StateData
local state = {
    mode = 'file',
    file_list = {},
    grep_files = {},
    history = {},
}

---Initialize/reset state
M.init = function()
    state.mode = 'file'
    state.file_list = {}
    state.grep_files = {}
    state.history = {}
end

---Set file list for grep mode
---@param paths string[] File paths
M.set_files = function(paths)
    state.file_list = paths or {}
end

---Set grep results for file mode
---@param paths string[] File paths with grep matches
M.set_grep_results = function(paths)
    state.grep_files = paths or {}
end

---Get current file list
---@return string[]
M.get_files = function()
    return state.file_list
end

---Get grep result files
---@return string[]
M.get_grep_results = function()
    return state.grep_files
end

---Get current mode
---@return string
M.get_mode = function()
    return state.mode
end

---Set current mode
---@param mode string Mode to set ('file' | 'grep')
M.set_mode = function(mode)
    if mode == 'file' or mode == 'grep' then
        state.mode = mode
    else
        error('Invalid mode: ' .. tostring(mode))
    end
end

---Add entry to history
---@param entry table History entry
M.add_history = function(entry)
    table.insert(state.history, entry)
end

---Get history
---@return table[]
M.get_history = function()
    return state.history
end

---Get full state (for debugging/testing)
---@return StateData
M.get_state = function()
    return vim.deepcopy(state)
end

return M
