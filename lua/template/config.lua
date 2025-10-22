-- Define config structure here, setup function will override defaults with user config
---@class TemplateConfig
local M = {}

---@class TemplateConfigOptions
---@field name string Name to greet. Default: 'World!'
---@field add_default_keybindings boolean Whether to add default keybindings. Default: true

---@type TemplateConfigOptions
local config = {
    name = 'World!',
    add_default_keybindings = true,
}

---@type TemplateConfigOptions
M.config = config

---Setup configuration with user options
---@param args TemplateConfigOptions?
M.setup = function(args)
    M.config = vim.tbl_deep_extend('force', M.config, args or {})
end

return M
