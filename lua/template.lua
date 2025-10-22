---@class Template
local M = {}

---Setup template.nvim with user configuration
---@param opts TemplateConfigOptions? User configuration options
M.setup = function(opts)
    require('template.config').setup(opts)
    require('template.commands').setup()
end

return M
