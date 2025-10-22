---@class Seeker
local M = {}

---Setup seeker.nvim with user configuration
---@param opts SeekerConfigOptions? User configuration options
M.setup = function(opts)
    require('seeker.config').setup(opts)
    require('seeker.commands').setup()
end

---Start seeker with optional configuration
---@param opts table? Optional picker configuration
M.seek = function(opts)
    require('seeker.picker').seek(opts)
end

return M
