describe('seeker.config', function()
    local config

    before_each(function()
        package.loaded['seeker.config'] = nil
        package.loaded['seeker.utils'] = nil
        config = require('seeker.config')
    end)

    describe('defaults', function()
        it('should have default toggle_key', function()
            assert.equals('<C-,>', config.config.toggle_key)
        end)

        it('should have notifications enabled by default', function()
            assert.is_true(config.config.notifications)
        end)

        it('should have default keybindings enabled', function()
            assert.is_true(config.config.add_default_keybindings)
        end)

        it('should have default picker_opts', function()
            assert.is_table(config.config.picker_opts)
            assert.is_table(config.config.picker_opts.layout)
        end)
    end)

    describe('setup', function()
        it('should merge user config with defaults', function()
            config.setup({
                toggle_key = '<C-s>',
                notifications = false,
            })

            assert.equals('<C-s>', config.config.toggle_key)
            assert.is_false(config.config.notifications)
            assert.is_true(config.config.add_default_keybindings)
        end)

        it('should deep merge picker_opts', function()
            config.setup({
                picker_opts = {
                    layout = {
                        preset = 'vertical',
                    },
                    custom_field = 'value',
                },
            })

            assert.equals('vertical', config.config.picker_opts.layout.preset)
            assert.equals('value', config.config.picker_opts.custom_field)
        end)

        it('should handle nil args', function()
            assert.has_no_error(function()
                config.setup(nil)
            end)
        end)

        it('should handle empty table', function()
            assert.has_no_error(function()
                config.setup({})
            end)
        end)
    end)

    describe('get', function()
        it('should return current config', function()
            config.setup({ toggle_key = '<C-x>' })
            local cfg = config.get()
            assert.equals('<C-x>', cfg.toggle_key)
        end)
    end)
end)
