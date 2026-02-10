describe('seeker.backends', function()
    local state
    local config_module

    before_each(function()
        package.loaded['seeker.state'] = nil
        package.loaded['seeker.config'] = nil
        state = require('seeker.state')
        config_module = require('seeker.config')
        state.init()
        config_module.setup({})
    end)

    describe('snacks backend', function()
        local backend

        before_each(function()
            package.loaded['seeker.backends.snacks'] = nil
            package.loaded['snacks'] = {
                picker = {
                    pick = function() end,
                    grep = function() end,
                    files = function() end,
                    git_files = function() end
                }
            }
            backend = require('seeker.backends.snacks')
        end)

        describe('create_grep_picker', function()
            it('should configure toggle action', function()
                local captured_opts
                package.loaded['snacks'].picker.grep = function(opts)
                    captured_opts = opts
                end

                backend.create_grep_picker({})

                assert.is_not_nil(captured_opts)
                assert.is_not_nil(captured_opts.actions)
                assert.is_not_nil(captured_opts.actions.seeker_toggle)
                assert.is_function(captured_opts.actions.seeker_toggle)
            end)

            it('should set dirs when file_list exists', function()
                state.set_files({ 'file1.lua', 'file2.lua' })

                local captured_opts
                package.loaded['snacks'].picker.grep = function(opts)
                    captured_opts = opts
                end

                backend.create_grep_picker({})

                assert.same({ 'file1.lua', 'file2.lua' }, captured_opts.dirs)
            end)

            it('should not set dirs when file_list is empty', function()
                state.set_files({})

                local captured_opts
                package.loaded['snacks'].picker.grep = function(opts)
                    captured_opts = opts
                end

                backend.create_grep_picker({})

                assert.is_nil(captured_opts.dirs)
            end)

            it('should call Snacks.picker.grep', function()
                local called = false
                package.loaded['snacks'].picker.grep = function(opts)
                    called = true
                end

                backend.create_grep_picker({})

                assert.is_true(called)
            end)
        end)

        describe('create_file_picker', function()
            it('should configure toggle action', function()
                local captured_opts
                package.loaded['snacks'].picker.files = function(opts)
                    captured_opts = opts
                end

                backend.create_file_picker({}, 'files')

                assert.is_not_nil(captured_opts)
                assert.is_not_nil(captured_opts.actions)
                assert.is_not_nil(captured_opts.actions.seeker_toggle)
                assert.is_function(captured_opts.actions.seeker_toggle)
            end)

            it('should use git_files when mode is git_files', function()
                local git_called = false
                package.loaded['snacks'].picker.git_files = function(opts)
                    git_called = true
                end

                backend.create_file_picker({}, 'git_files')

                assert.is_true(git_called)
            end)

            it('should use files when mode is files', function()
                local files_called = false
                package.loaded['snacks'].picker.files = function(opts)
                    files_called = true
                end

                backend.create_file_picker({}, 'files')

                assert.is_true(files_called)
            end)

            it('should use custom finder when grep_files exist', function()
                state.set_grep_results({ 'file1.lua', 'file2.lua' })

                local captured_opts
                package.loaded['snacks'].picker.pick = function(source, opts)
                    captured_opts = opts
                end

                backend.create_file_picker({})

                assert.is_not_nil(captured_opts)
                assert.is_not_nil(captured_opts.finder)
                assert.is_function(captured_opts.finder)
            end)
        end)

        describe('create_grep_word_picker', function()
            it('should configure toggle action', function()
                local captured_opts
                package.loaded['snacks'].picker.pick = function(source, opts)
                    captured_opts = opts
                end

                backend.create_grep_word_picker({})

                assert.is_not_nil(captured_opts)
                assert.is_not_nil(captured_opts.actions)
                assert.is_not_nil(captured_opts.actions.seeker_toggle)
                assert.is_function(captured_opts.actions.seeker_toggle)
            end)

            it('should configure toggle key binding', function()
                local captured_opts
                package.loaded['snacks'].picker.pick = function(source, opts)
                    captured_opts = opts
                end

                backend.create_grep_word_picker({})

                local toggle_key = config_module.get().toggle_key
                assert.is_not_nil(captured_opts.win)
                assert.is_not_nil(captured_opts.win.input)
                assert.is_not_nil(captured_opts.win.input.keys)
                assert.is_not_nil(captured_opts.win.input.keys[toggle_key])
                assert.equals('seeker_toggle', captured_opts.win.input.keys[toggle_key][1])
            end)

            it('should set dirs when file_list exists', function()
                state.set_files({ 'file1.lua', 'file2.lua' })

                local captured_opts
                package.loaded['snacks'].picker.pick = function(source, opts)
                    captured_opts = opts
                end

                backend.create_grep_word_picker({})

                assert.same({ 'file1.lua', 'file2.lua' }, captured_opts.dirs)
            end)

            it('should not set dirs when file_list is empty', function()
                state.set_files({})

                local captured_opts
                package.loaded['snacks'].picker.pick = function(source, opts)
                    captured_opts = opts
                end

                backend.create_grep_word_picker({})

                assert.is_nil(captured_opts.dirs)
            end)

            it('should merge custom picker_opts', function()
                local captured_opts
                package.loaded['snacks'].picker.pick = function(source, opts)
                    captured_opts = opts
                end

                backend.create_grep_word_picker({ custom_option = 'test_value' })

                assert.equals('test_value', captured_opts.custom_option)
            end)

            it('should call Snacks.picker.pick with grep_word source', function()
                local captured_source
                package.loaded['snacks'].picker.pick = function(source, opts)
                    captured_source = source
                end

                backend.create_grep_word_picker({})

                assert.equals('grep_word', captured_source)
            end)
        end)
    end)

    describe('telescope backend', function()
        local backend

        before_each(function()
            package.loaded['seeker.backends.telescope'] = nil
            package.loaded['telescope.builtin'] = {
                grep_string = function() end,
                live_grep = function() end,
                find_files = function() end,
                git_files = function() end
            }
            backend = require('seeker.backends.telescope')
        end)

        describe('create_grep_picker', function()
            it('should configure attach_mappings', function()
                local captured_opts
                package.loaded['telescope.builtin'].live_grep = function(opts)
                    captured_opts = opts
                end

                backend.create_grep_picker({})

                assert.is_not_nil(captured_opts)
                assert.is_not_nil(captured_opts.attach_mappings)
                assert.is_function(captured_opts.attach_mappings)
            end)

            it('should set search_dirs when file_list exists', function()
                state.set_files({ 'file1.lua', 'file2.lua' })

                local captured_opts
                package.loaded['telescope.builtin'].live_grep = function(opts)
                    captured_opts = opts
                end

                backend.create_grep_picker({})

                assert.same({ 'file1.lua', 'file2.lua' }, captured_opts.search_dirs)
            end)

            it('should call builtin.live_grep', function()
                local called = false
                package.loaded['telescope.builtin'].live_grep = function(opts)
                    called = true
                end

                backend.create_grep_picker({})

                assert.is_true(called)
            end)
        end)

        describe('create_file_picker', function()
            it('should configure attach_mappings', function()
                local captured_opts
                package.loaded['telescope.builtin'].find_files = function(opts)
                    captured_opts = opts
                end

                backend.create_file_picker({}, 'files')

                assert.is_not_nil(captured_opts)
                assert.is_not_nil(captured_opts.attach_mappings)
                assert.is_function(captured_opts.attach_mappings)
            end)

            it('should use git_files when mode is git_files', function()
                local git_called = false
                package.loaded['telescope.builtin'].git_files = function(opts)
                    git_called = true
                end

                backend.create_file_picker({}, 'git_files')

                assert.is_true(git_called)
            end)

            it('should use find_files when mode is files', function()
                local files_called = false
                package.loaded['telescope.builtin'].find_files = function(opts)
                    files_called = true
                end

                backend.create_file_picker({}, 'files')

                assert.is_true(files_called)
            end)
        end)

        describe('create_grep_word_picker', function()
            it('should configure attach_mappings', function()
                local captured_opts
                package.loaded['telescope.builtin'].grep_string = function(opts)
                    captured_opts = opts
                end

                backend.create_grep_word_picker({})

                assert.is_not_nil(captured_opts)
                assert.is_not_nil(captured_opts.attach_mappings)
                assert.is_function(captured_opts.attach_mappings)
            end)

            it('should set search_dirs when file_list exists', function()
                state.set_files({ 'file1.lua', 'file2.lua' })

                local captured_opts
                package.loaded['telescope.builtin'].grep_string = function(opts)
                    captured_opts = opts
                end

                backend.create_grep_word_picker({})

                assert.same({ 'file1.lua', 'file2.lua' }, captured_opts.search_dirs)
            end)

            it('should not set search_dirs when file_list is empty', function()
                state.set_files({})

                local captured_opts
                package.loaded['telescope.builtin'].grep_string = function(opts)
                    captured_opts = opts
                end

                backend.create_grep_word_picker({})

                assert.is_nil(captured_opts.search_dirs)
            end)

            it('should merge custom picker_opts', function()
                local captured_opts
                package.loaded['telescope.builtin'].grep_string = function(opts)
                    captured_opts = opts
                end

                backend.create_grep_word_picker({ custom_option = 'test_value' })

                assert.equals('test_value', captured_opts.custom_option)
            end)

            it('should call builtin.grep_string', function()
                local called = false
                package.loaded['telescope.builtin'].grep_string = function(opts)
                    called = true
                end

                backend.create_grep_word_picker({})

                assert.is_true(called)
            end)
        end)
    end)
end)
