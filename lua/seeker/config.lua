---@class SeekerConfig
local M = {}

---@class SeekerConfigOptions
---@field picker_provider string? Picker provider to use: 'snacks' or 'telescope' (default: 'snacks')
---@field toggle_key string? Key to toggle between file and grep mode (default: '<C-e>')
---@field picker_opts table? Options passed to the picker provider
---@type SeekerConfigOptions
local config = {
    picker_provider = 'snacks',
    toggle_key = '<C-e>',
    picker_opts = {},
}

---@type SeekerConfigOptions
M.config = config

---Setup configuration with user options
---@param args SeekerConfigOptions?
M.setup = function(args)
    M.config = vim.tbl_deep_extend('force', M.config, args or {})
end

---Get the current configuration
---@return SeekerConfigOptions
M.get = function()
    return M.config
end

return M
