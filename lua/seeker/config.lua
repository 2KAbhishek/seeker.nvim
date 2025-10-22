---@class SeekerConfig
local M = {}

---@class SeekerConfigOptions
---@field toggle_key string? Key to toggle between file and grep mode (default: '<C-e>')
---@field picker_opts table? Options passed to snacks.picker
---@field add_default_keybindings boolean? Whether to add default keybindings (default: true)

---@type SeekerConfigOptions
local config = {
    toggle_key = '<C-e>',
    picker_opts = {},
    add_default_keybindings = true,
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
