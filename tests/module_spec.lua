local template = require('template')
local module = require('template.module')

describe('greet', function()
    it('returns message with config value', function()
        template.setup()
        assert(module.greet() == 'Hello World!')
    end)

    it('returns message with user arg', function()
        template.setup()
        assert(module.greet('Neovim') == 'Hello Neovim')
    end)
end)
