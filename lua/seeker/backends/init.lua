---@class SeekerBackends
local M = {}

local config_module = require('seeker.config')

---Get the appropriate backend based on configuration
---@return table Backend module (snacks or telescope)
M.get_backend = function()
    local config = config_module.get()
    local provider = config.picker_provider or 'snacks'

    if provider == 'telescope' then
        local ok, telescope = pcall(require, 'telescope')
        if not ok then
            vim.notify(
                'seeker.nvim: telescope.nvim not found, falling back to snacks.nvim',
                vim.log.levels.WARN
            )
            provider = 'snacks'
        end
    end

    if provider == 'snacks' then
        local ok, snacks = pcall(require, 'snacks')
        if not ok then
            error('seeker.nvim: snacks.nvim is required but not found')
        end
    end

    local backend_path = 'seeker.backends.' .. provider
    local ok, backend = pcall(require, backend_path)

    if not ok then
        error('seeker.nvim: Failed to load backend "' .. provider .. '"')
    end

    return backend
end

---Check if a picker provider is available
---@param provider string 'snacks' or 'telescope'
---@return boolean Available
M.is_available = function(provider)
    if provider == 'snacks' then
        return pcall(require, 'snacks')
    elseif provider == 'telescope' then
        return pcall(require, 'telescope')
    end
    return false
end

return M
