---@class SeekerPicker
local M = {}

local state = require('seeker.state')
local backends = require('seeker.backends')

---Main entry point for seeker
---@param opts table? Optional configuration with mode field
M.seek = function(opts)
    opts = opts or {}
    state.init()

    local backend = backends.get_backend()
    local mode = opts.mode
    local picker_opts = opts.picker_opts or {}

    if mode == 'grep' then
        backend.create_grep_picker(picker_opts)
    elseif mode == 'files' or mode == 'git_files' then
        backend.create_file_picker(picker_opts, mode)
    else
        backend.create_file_picker(picker_opts)
    end
end

return M
