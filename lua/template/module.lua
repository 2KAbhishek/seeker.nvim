---@class TemplateModule
local M = {}

local config = require('template.config').config

---Greet with a personalized message
---@param name string? Name to greet, uses config.name if not provided
---@return string greeting The greeting message
M.greet = function(name)
    name = name and #name > 0 and name or config.name

    local greeting = 'Hello ' .. name
    M.show_notification(greeting)
    return greeting
end

---Show a notification with template branding
---@param message string Message to display
M.show_notification = function(message)
    if not message or #message == 0 then
        message = 'Hello from Template!'
    end

    vim.notify(message, vim.log.levels.INFO, {
        title = 'Template',
        timeout = 5000,
    })
end

return M
