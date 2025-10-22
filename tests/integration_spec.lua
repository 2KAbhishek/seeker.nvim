describe('seeker integration', function()
    local seeker
    local state
    local utils

    before_each(function()
        package.loaded['seeker'] = nil
        package.loaded['seeker.state'] = nil
        package.loaded['seeker.config'] = nil
        package.loaded['seeker.picker'] = nil
        package.loaded['seeker.utils'] = nil

        seeker = require('seeker')
        state = require('seeker.state')
        utils = require('seeker.utils')
    end)

    describe('setup', function()
        it('should setup seeker with default config', function()
            assert.has_no_error(function()
                seeker.setup()
            end)
        end)

        it('should setup seeker with custom config', function()
            assert.has_no_error(function()
                seeker.setup({
                    toggle_key = '<C-x>',
                    notifications = false,
                })
            end)

            local config = require('seeker.config').get()
            assert.equals('<C-x>', config.toggle_key)
            assert.is_false(config.notifications)
        end)
    end)

    describe('state workflow', function()
        it('should track file to grep to file workflow', function()
            state.init()
            assert.equals('file', state.get_mode())

            state.set_mode('grep')
            state.set_files({ 'test1.lua', 'test2.lua' })
            assert.equals('grep', state.get_mode())
            assert.equals(2, #state.get_files())

            state.set_mode('file')
            state.set_grep_results({ 'test1.lua' })
            assert.equals('file', state.get_mode())
            assert.equals(1, #state.get_grep_results())
        end)
    end)

    describe('path extraction workflow', function()
        it('should extract paths from file picker items', function()
            local file_items = { 'file1.lua', 'file2.lua', 'file3.lua' }
            local paths = utils.extract_file_paths(file_items)
            assert.equals(3, #paths)
        end)

        it('should extract unique files from grep results', function()
            local grep_items = {
                { filename = 'test.lua', lnum = 1, text = 'match' },
                { filename = 'test.lua', lnum = 10, text = 'match' },
                { filename = 'other.lua', lnum = 5, text = 'match' },
            }
            local files = utils.get_unique_files(grep_items)
            assert.equals(2, #files)
            assert.same({ 'test.lua', 'other.lua' }, files)
        end)
    end)

    describe('progressive refinement workflow', function()
        it('should maintain refinement across mode switches', function()
            state.init()

            local initial_files = { 'file1.lua', 'file2.lua', 'file3.lua' }
            state.set_files(initial_files)
            state.set_mode('grep')

            assert.equals(3, #state.get_files())

            state.set_grep_results({ 'file1.lua', 'file2.lua' })
            state.set_mode('file')

            assert.equals(2, #state.get_grep_results())

            state.set_files({ 'file1.lua', 'file2.lua' })
            state.set_mode('grep')

            assert.equals(2, #state.get_files())

            state.set_grep_results({ 'file1.lua' })
            state.set_mode('file')

            assert.equals(1, #state.get_grep_results())
        end)
    end)

    describe('config integration', function()
        it('should auto-detect git repository', function()
            local config_module = require('seeker.config')
            config_module.setup()

            local config = config_module.get()
            assert.is_not_nil(config.picker_type)
            assert.is_boolean(config.use_git_files)
        end)

        it('should respect user picker_type preference', function()
            local config_module = require('seeker.config')
            config_module.setup({ picker_type = 'files' })

            local config = config_module.get()
            assert.equals('files', config.picker_type)
        end)
    end)

    describe('edge cases', function()
        it('should handle empty file lists', function()
            state.init()
            state.set_files({})
            assert.same({}, state.get_files())
        end)

        it('should handle nil inputs', function()
            state.init()
            state.set_files(nil)
            state.set_grep_results(nil)
            assert.same({}, state.get_files())
            assert.same({}, state.get_grep_results())
        end)

        it('should extract paths from empty items', function()
            assert.same({}, utils.extract_file_paths({}))
            assert.same({}, utils.extract_file_paths(nil))
        end)

        it('should handle items without valid paths', function()
            local items = { {}, { invalid = true }, nil }
            local paths = utils.extract_file_paths(items)
            assert.same({}, paths)
        end)
    end)
end)
