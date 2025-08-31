local config = function()
    local status_ok, lualine = pcall(require, 'lualine')
    if not status_ok then
        return
    end

    local shorten_filename = function(filename)
        local max_length = 20

        local dot_index = filename:find('%.[^%.]*$', 1)
        local base_name, extension
        if dot_index then
            base_name = filename:sub(1, dot_index - 1)
            extension = filename:sub(dot_index)
        else
            base_name = filename
            extension = ''
        end
        local current_length = vim.fn.strdisplaywidth(base_name)

        if current_length > max_length then
            base_name = vim.fn.strcharpart(base_name, 0, max_length) .. '..'
            if extension == '' then
                base_name = base_name .. '.'
            end
        end

        return base_name .. extension
    end

    local shorten_file_path = function()
        local max_length = 30
        local path = vim.fn.expand '%:~:.'
        local len = vim.fn.strdisplaywidth(path)

        if len <= max_length then
            return path
        end

        local sep = '\\'
        local separators = { '/', '\\', ':', '\\\\' }
        local pattern = table.concat(separators, '')
        local normalized_path = path:gsub('[' .. pattern .. ']', sep)
        local segments = vim.split(normalized_path, sep)
        for idx = 1, #segments - 1 do
            if len <= max_length then
                break
            end

            local segment = segments[idx]
            local shortened = vim.fn.strcharpart(segment, 0, vim.startswith(segment, '.') and 2 or 1)
            segments[idx] = shortened
            len = len - (vim.fn.strdisplaywidth(segment) - vim.fn.strdisplaywidth(shortened))
        end
        segments[#segments] = shorten_filename(segments[#segments])

        return table.concat(segments, sep)
    end

    lualine.setup {
        options = {
            icons_enabled = false,
            component_separators = '',
            section_separators = '',
        },

        sections = {
            lualine_a = { 'mode' },
            lualine_b = {
                {
                    'buffers',
                    show_filename_only = true, -- Shows shortened relative path when set to false.
                    hide_filename_extension = false, -- Hide filename extension when set to true.
                    show_modified_status = true, -- Shows indicator when the buffer is modified.
                    mode = 0, -- 0: Shows buffer name
                    filetype_names = {
                        TelescopePrompt = 'Telescope',
                        dashboard = 'Dashboard',
                        fzf = 'FZF',
                        alpha = 'Alpha',
                        NvimTree = 'NvimTree',
                        Term = 'Term',
                        oil = 'Oil',
                    }, -- Shows specific buffer name for that filetype ( { `filetype` = `buffer_name`, ... } )
                    use_mode_colors = true,
                    symbols = {
                        modified = ' ●',
                        alternate_file = false,
                        directory = '',
                    },
                    fmt = shorten_filename,
                },
            },
            lualine_c = {},
            lualine_x = {
                'diagnostics',
                {
                    'diff',
                    icons_enabled = true,
                    colored = true, -- Displays a colored diff status if set to true
                    diff_color = {
                        -- Same color values as the general color option can be used here.
                        added = 'LuaLineDiffAdd', -- Changes the diff"s added color
                        modified = 'LuaLineDiffChange', -- Changes the diff"s modified color
                        removed = 'LuaLineDiffDelete', -- Changes the diff"s removed color you
                    },
                    symbols = { added = '+', modified = '~', removed = '-' }, -- Changes the symbols used by the diff.
                    source = nil, -- A function that works as a data source for diff.
                    -- It must return a table as such:
                    --     { added = add_count, modified = modified_count, removed = removed_count }
                    -- or nil on failure. count <= 0 won"t be displayed.
                },
                {
                    'branch',
                    icons_enabled = true,
                    icon = {
                        '',
                        color = {
                            fg = 'white',
                        },
                    },
                },
            },
            lualine_y = {
                {
                    shorten_file_path,
                    padding = { left = 2, right = 2 },
                    cond = function()
                        return vim.fn.empty(vim.fn.expand '%:t') ~= 1
                            and string.find(vim.fn.expand '%:p', 'term://') == nil
                            and string.find(vim.fn.expand '%:p', 'NvimTree') == nil
                    end,
                    color = 'StatusLine',
                },
                -- 'encoding',
                -- 'filetype',
            },
            lualine_z = { 'progress' },
        },
        extensions = {
            'oil',
            'lazy',
            'fugitive',
        },
    }
end

-- Change statusline
return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = config,
}
