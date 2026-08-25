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
                })
            end)

            local config = require('seeker.config').get()
            assert.equals('<C-x>', config.toggle_key)
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

        it('should handle exclusion workflow from file to grep', function()
            state.init()

            local all_files = { 'file1.lua', 'file2.lua', 'file3.lua' }
            local excluded = { 'file3.lua' }
            local remaining = utils.filter_excluded_paths(all_files, excluded)

            state.set_files(remaining)
            state.set_mode('grep')

            assert.equals(2, #state.get_files())
            assert.same({ 'file1.lua', 'file2.lua' }, state.get_files())
        end)

        it('should handle exclusion workflow from grep to file', function()
            state.init()

            local grep_files = { 'file1.lua', 'file2.lua', 'file3.lua' }
            local excluded = { 'file2.lua' }
            local remaining = utils.filter_excluded_paths(grep_files, excluded)

            state.set_grep_results(remaining)
            state.set_mode('file')

            assert.equals(2, #state.get_grep_results())
            assert.same({ 'file1.lua', 'file3.lua' }, state.get_grep_results())
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

    describe('command integration', function()
        it('should pass visual selection to grep_word command when range is provided', function()
            local seeker = require('seeker')
            seeker.setup({})

            local orig_getpos = vim.fn.getpos
            local orig_lines = vim.api.nvim_buf_get_lines
            local orig_mode = vim.fn.mode

            vim.fn.mode = function()
                return 'n'
            end
            vim.fn.getpos = function(mark)
                if mark == "'<" then
                    return { 0, 1, 1, 0 }
                elseif mark == "'>" then
                    return { 0, 1, 11, 0 }
                end
                return { 0, 0, 0, 0 }
            end
            vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'test_target' })
            vim.api.nvim_buf_set_mark(0, '<', 1, 0, {})
            vim.api.nvim_buf_set_mark(0, '>', 1, 10, {})

            local captured_opts
            package.loaded['snacks'] = {
                picker = {
                    pick = function(source, opts)
                        captured_opts = opts
                    end,
                    files = function() end,
                    git_files = function() end,
                    grep = function() end,
                }
            }

            vim.cmd("'<,'>Seeker grep_word")

            assert.is_not_nil(captured_opts)
            assert.equals('test_target', captured_opts.search)

            vim.fn.getpos = orig_getpos
            vim.api.nvim_buf_get_lines = orig_lines
            vim.fn.mode = orig_mode
        end)
    end)
end)
