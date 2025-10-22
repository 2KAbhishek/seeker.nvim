---@class SeekerConfig
local M = {}

---@class SeekerConfigOptions
---@field picker_type string? 'git_files' or 'files' (auto-detect if not specified)
---@field toggle_key string? Key to toggle between file and grep mode (default: '<C-e>')
---@field use_git_files boolean? Whether to use git_files (auto-detect if nil)
---@field picker_opts table? Options passed to snacks.picker
---@field notifications boolean? Show notifications on mode switch (default: true)
---@field add_default_keybindings boolean? Whether to add default keybindings (default: true)

---@type SeekerConfigOptions
local config = {
    picker_type = nil,
    toggle_key = '<C-e>',
    use_git_files = nil,
    picker_opts = {},
    notifications = true,
    add_default_keybindings = true,
}

---@type SeekerConfigOptions
M.config = config

---Setup configuration with user options
---@param args SeekerConfigOptions?
M.setup = function(args)
    M.config = vim.tbl_deep_extend('force', M.config, args or {})

    if M.config.use_git_files == nil then
        local utils = require('seeker.utils')
        M.config.use_git_files = utils.is_git_repo()
    end

    if M.config.picker_type == nil then
        M.config.picker_type = M.config.use_git_files and 'git_files' or 'files'
    end
end

---Get the current configuration
---@return SeekerConfigOptions
M.get = function()
    return M.config
end

return M
