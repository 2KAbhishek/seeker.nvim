describe('seeker.picker', function()
    local picker = require('seeker.picker')
    local config = require('seeker.config')
    local backends = require('seeker.backends')

    before_each(function()
        config.setup({})
    end)

    describe('seek with custom picker_opts', function()
        it('should pass custom picker_opts to backend create_file_picker', function()
            local mock_backend = {
                create_file_picker = function(custom_picker_opts, mode)
                    assert.equals('test_value', custom_picker_opts.test_option)
                    assert.equals('files', mode)
                end,
                create_grep_picker = function() end
            }

            backends.get_backend = function()
                return mock_backend
            end

            picker.seek({
                mode = 'files',
                picker_opts = {
                    test_option = 'test_value'
                }
            })
        end)

        it('should pass custom picker_opts to backend create_grep_picker', function()
            local mock_backend = {
                create_file_picker = function() end,
                create_grep_picker = function(custom_picker_opts)
                    assert.equals('grep_test_value', custom_picker_opts.grep_option)
                end
            }

            backends.get_backend = function()
                return mock_backend
            end

            picker.seek({
                mode = 'grep',
                picker_opts = {
                    grep_option = 'grep_test_value'
                }
            })
        end)

        it('should handle empty picker_opts gracefully', function()
            local mock_backend = {
                create_file_picker = function(custom_picker_opts, mode)
                    assert.same({}, custom_picker_opts)
                end,
                create_grep_picker = function() end
            }

            backends.get_backend = function()
                return mock_backend
            end

            picker.seek({
                mode = 'files'
            })
        end)

        it('should handle nil picker_opts gracefully', function()
            local mock_backend = {
                create_file_picker = function(custom_picker_opts, mode)
                    assert.same({}, custom_picker_opts)
                end,
                create_grep_picker = function() end
            }

            backends.get_backend = function()
                return mock_backend
            end

            picker.seek({
                mode = 'files',
                picker_opts = nil
            })
        end)

        it('should default to file picker when mode is not specified', function()
            local mock_backend = {
                create_file_picker = function(custom_picker_opts, mode)
                    assert.equals('default_value', custom_picker_opts.default_option)
                    assert.is_nil(mode)
                end,
                create_grep_picker = function() end
            }

            backends.get_backend = function()
                return mock_backend
            end

            picker.seek({
                picker_opts = {
                    default_option = 'default_value'
                }
            })
        end)

        it('should support git_files mode with custom options', function()
            local mock_backend = {
                create_file_picker = function(custom_picker_opts, mode)
                    assert.equals('git_value', custom_picker_opts.git_option)
                    assert.equals('git_files', mode)
                end,
                create_grep_picker = function() end
            }

            backends.get_backend = function()
                return mock_backend
            end

            picker.seek({
                mode = 'git_files',
                picker_opts = {
                    git_option = 'git_value'
                }
            })
        end)

        it('should pass custom picker_opts to backend create_grep_word_picker', function()
            local mock_backend = {
                create_file_picker = function() end,
                create_grep_picker = function() end,
                create_grep_word_picker = function(custom_picker_opts)
                    assert.equals('grep_word_test_value', custom_picker_opts.grep_word_option)
                end
            }

            backends.get_backend = function()
                return mock_backend
            end

            picker.seek({
                mode = 'grep_word',
                picker_opts = {
                    grep_word_option = 'grep_word_test_value'
                }
            })
        end)
    end)

    describe('backend state isolation', function()
        local state

        before_each(function()
            package.loaded['seeker.state'] = nil
            state = require('seeker.state')
            state.init()
        end)

        it('should not modify state when creating grep_word picker with snacks backend', function()
            package.loaded['seeker.backends.snacks'] = nil
            package.loaded['snacks'] = {
                picker = {
                    pick = function() end
                }
            }

            local backend = require('seeker.backends.snacks')

            state.init()
            assert.equals('file', state.get_mode())

            backend.create_grep_word_picker({})

            assert.equals('file', state.get_mode())
        end)

        it('should not modify state when creating grep picker with snacks backend', function()
            package.loaded['seeker.backends.snacks'] = nil
            package.loaded['snacks'] = {
                picker = {
                    grep = function() end
                }
            }

            local backend = require('seeker.backends.snacks')

            state.init()
            assert.equals('file', state.get_mode())

            backend.create_grep_picker({})

            assert.equals('file', state.get_mode())
        end)

        it('should not modify state when creating file picker with snacks backend', function()
            package.loaded['seeker.backends.snacks'] = nil
            package.loaded['snacks'] = {
                picker = {
                    files = function() end,
                    git_files = function() end
                }
            }

            local backend = require('seeker.backends.snacks')

            state.set_mode('grep')
            assert.equals('grep', state.get_mode())

            backend.create_file_picker({})

            assert.equals('grep', state.get_mode())
        end)

        it('should not modify state when creating grep_word picker with telescope backend', function()
            package.loaded['seeker.backends.telescope'] = nil
            package.loaded['telescope.builtin'] = {
                grep_string = function() end
            }

            local backend = require('seeker.backends.telescope')

            state.init()
            assert.equals('file', state.get_mode())

            backend.create_grep_word_picker({})

            assert.equals('file', state.get_mode())
        end)
    end)
end)
