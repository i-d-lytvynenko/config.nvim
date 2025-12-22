-- Change statusline
local config = function()
    local status_ok, lualine = pcall(require, 'lualine')
    if not status_ok then
        return
    end

    local utils = require 'utils'

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
                        iron = 'REPL',
                    }, -- Shows specific buffer name for that filetype ( { `filetype` = `buffer_name`, ... } )
                    use_mode_colors = true,
                    symbols = {
                        modified = ' ●',
                        alternate_file = false,
                        directory = '',
                    },
                    fmt = utils.shorten_filename,
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
                    function(opts)
                        opts = opts or {}
                        local path_sep = package.config:sub(1, 1)
                        local from_path = vim.fn.getcwd() .. path_sep
                        local to_path = vim.F.if_nil(opts.path, vim.fn.expand '%:p')
                        return utils.get_relative_path(from_path, to_path)
                    end,
                    utils.shorten_file_path,
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

return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = config,
}
