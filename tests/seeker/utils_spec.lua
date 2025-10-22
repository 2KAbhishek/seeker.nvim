describe('seeker.utils', function()
    local utils

    before_each(function()
        package.loaded['seeker.utils'] = nil
        utils = require('seeker.utils')
    end)

    describe('extract_file_paths', function()
        it('should extract paths from string items', function()
            local items = { 'file1.lua', 'file2.lua', 'file3.lua' }
            local paths = utils.extract_file_paths(items)
            assert.same(items, paths)
        end)

        it('should extract paths from table items with file field', function()
            local items = {
                { file = 'test1.lua', line = 10 },
                { file = 'test2.lua', line = 20 },
            }
            local paths = utils.extract_file_paths(items)
            assert.same({ 'test1.lua', 'test2.lua' }, paths)
        end)

        it('should extract paths from table items with path field', function()
            local items = {
                { path = 'src/main.lua' },
                { path = 'src/util.lua' },
            }
            local paths = utils.extract_file_paths(items)
            assert.same({ 'src/main.lua', 'src/util.lua' }, paths)
        end)

        it('should extract paths from table items with filename field', function()
            local items = {
                { filename = 'grep1.lua', lnum = 5, text = 'match' },
                { filename = 'grep2.lua', lnum = 10, text = 'match' },
            }
            local paths = utils.extract_file_paths(items)
            assert.same({ 'grep1.lua', 'grep2.lua' }, paths)
        end)

        it('should handle mixed item types', function()
            local items = {
                'string_file.lua',
                { file = 'table_file.lua' },
                { path = 'table_path.lua' },
            }
            local paths = utils.extract_file_paths(items)
            assert.same({ 'string_file.lua', 'table_file.lua', 'table_path.lua' }, paths)
        end)

        it('should return unique paths', function()
            local items = {
                'file1.lua',
                'file2.lua',
                'file1.lua',
                { file = 'file2.lua' },
            }
            local paths = utils.extract_file_paths(items)
            assert.same({ 'file1.lua', 'file2.lua' }, paths)
        end)

        it('should handle empty items', function()
            assert.same({}, utils.extract_file_paths({}))
        end)

        it('should handle nil items', function()
            assert.same({}, utils.extract_file_paths(nil))
        end)

        it('should skip items without path information', function()
            local items = {
                'valid_file.lua',
                { no_path = true },
                {},
                'another_valid.lua',
            }
            local paths = utils.extract_file_paths(items)
            assert.same({ 'valid_file.lua', 'another_valid.lua' }, paths)
        end)
    end)

    describe('get_unique_files', function()
        it('should extract unique files from grep results', function()
            local grep_items = {
                { filename = 'test.lua', lnum = 1 },
                { filename = 'test.lua', lnum = 10 },
                { filename = 'other.lua', lnum = 5 },
            }
            local files = utils.get_unique_files(grep_items)
            assert.same({ 'test.lua', 'other.lua' }, files)
        end)
    end)

    describe('normalize_paths', function()
        it('should keep absolute paths unchanged', function()
            local paths = { '/absolute/path/file.lua' }
            local normalized = utils.normalize_paths(paths, '/some/cwd')
            assert.same(paths, normalized)
        end)

        it('should convert relative paths to absolute', function()
            local cwd = '/test/project'
            local paths = { 'src/file.lua', 'lib/util.lua' }
            local normalized = utils.normalize_paths(paths, cwd)
            assert.equals(2, #normalized)
            assert.truthy(normalized[1]:find('/test/project/src/file.lua'))
            assert.truthy(normalized[2]:find('/test/project/lib/util.lua'))
        end)

        it('should handle empty paths', function()
            assert.same({}, utils.normalize_paths({}))
        end)

        it('should handle nil paths', function()
            assert.same({}, utils.normalize_paths(nil))
        end)
    end)

    describe('validate_files', function()
        it('should separate valid and invalid files', function()
            local test_file = vim.fn.tempname()
            vim.fn.writefile({ 'test content' }, test_file)

            local paths = { test_file, '/nonexistent/file.lua' }
            local valid, invalid = utils.validate_files(paths)

            assert.equals(1, #valid)
            assert.equals(1, #invalid)
            assert.equals(test_file, valid[1])
            assert.equals('/nonexistent/file.lua', invalid[1])

            vim.fn.delete(test_file)
        end)

        it('should handle empty paths', function()
            local valid, invalid = utils.validate_files({})
            assert.same({}, valid)
            assert.same({}, invalid)
        end)

        it('should handle nil paths', function()
            local valid, invalid = utils.validate_files(nil)
            assert.same({}, valid)
            assert.same({}, invalid)
        end)
    end)

    describe('to_relative_paths', function()
        it('should convert paths to relative', function()
            local cwd = vim.fn.getcwd()
            local paths = { cwd .. '/test.lua', cwd .. '/src/main.lua' }
            local relative = utils.to_relative_paths(paths)
            assert.equals(2, #relative)
        end)

        it('should handle empty paths', function()
            assert.same({}, utils.to_relative_paths({}))
        end)

        it('should handle nil paths', function()
            assert.same({}, utils.to_relative_paths(nil))
        end)
    end)

    describe('get_picker_items', function()
        it('should return selected items if available', function()
            local picker = {
                selected = function()
                    return { 'selected1.lua', 'selected2.lua' }
                end,
                items = function()
                    return { 'item1.lua', 'item2.lua', 'item3.lua' }
                end,
            }
            local items = utils.get_picker_items(picker)
            assert.same({ 'selected1.lua', 'selected2.lua' }, items)
        end)

        it('should return all items if no selection', function()
            local picker = {
                selected = function()
                    return {}
                end,
                items = function()
                    return { 'item1.lua', 'item2.lua' }
                end,
            }
            local items = utils.get_picker_items(picker)
            assert.same({ 'item1.lua', 'item2.lua' }, items)
        end)

        it('should handle nil picker', function()
            assert.same({}, utils.get_picker_items(nil))
        end)
    end)

    describe('is_git_repo', function()
        it('should detect git repository', function()
            local result = utils.is_git_repo()
            assert.is_boolean(result)
        end)
    end)
end)
