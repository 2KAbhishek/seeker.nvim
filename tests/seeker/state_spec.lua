describe('seeker.state', function()
    local state

    before_each(function()
        package.loaded['seeker.state'] = nil
        state = require('seeker.state')
        state.init()
    end)

    describe('init', function()
        it('should initialize state with defaults', function()
            state.init()
            local s = state.get_state()
            assert.equals('file', s.mode)
            assert.same({}, s.file_list)
            assert.same({}, s.grep_files)
            assert.same({}, s.history)
        end)
    end)

    describe('mode management', function()
        it('should get default mode', function()
            assert.equals('file', state.get_mode())
        end)

        it('should set mode to grep', function()
            state.set_mode('grep')
            assert.equals('grep', state.get_mode())
        end)

        it('should set mode to file', function()
            state.set_mode('file')
            assert.equals('file', state.get_mode())
        end)

        it('should error on invalid mode', function()
            assert.has_error(function()
                state.set_mode('invalid')
            end)
        end)
    end)

    describe('file list management', function()
        it('should set file list', function()
            local files = { 'test1.lua', 'test2.lua' }
            state.set_files(files)
            assert.same(files, state.get_files())
        end)

        it('should handle empty file list', function()
            state.set_files({})
            assert.same({}, state.get_files())
        end)

        it('should handle nil file list', function()
            state.set_files(nil)
            assert.same({}, state.get_files())
        end)
    end)

    describe('grep results management', function()
        it('should set grep results', function()
            local files = { 'match1.lua', 'match2.lua' }
            state.set_grep_results(files)
            assert.same(files, state.get_grep_results())
        end)

        it('should handle empty grep results', function()
            state.set_grep_results({})
            assert.same({}, state.get_grep_results())
        end)

        it('should handle nil grep results', function()
            state.set_grep_results(nil)
            assert.same({}, state.get_grep_results())
        end)
    end)

    describe('history management', function()
        it('should add history entry', function()
            local entry = { mode = 'file', files = { 'test.lua' } }
            state.add_history(entry)
            local history = state.get_history()
            assert.equals(1, #history)
            assert.same(entry, history[1])
        end)

        it('should add multiple history entries', function()
            state.add_history({ mode = 'file' })
            state.add_history({ mode = 'grep' })
            state.add_history({ mode = 'file' })
            local history = state.get_history()
            assert.equals(3, #history)
        end)

        it('should clear history on init', function()
            state.add_history({ mode = 'file' })
            state.init()
            assert.same({}, state.get_history())
        end)
    end)

    describe('get_state', function()
        it('should return a copy of the state', function()
            state.set_mode('grep')
            state.set_files({ 'test.lua' })
            local s = state.get_state()
            assert.equals('grep', s.mode)
            assert.same({ 'test.lua' }, s.file_list)

            s.mode = 'file'
            assert.equals('grep', state.get_mode())
        end)
    end)
end)
