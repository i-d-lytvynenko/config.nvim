-- Change statusline
local config = function()
    local status_ok, lualine = pcall(require, 'lualine')
    if not status_ok then
        return
    end

    local utils = require 'utils'
    vim.api.nvim_create_autocmd('User', {
        pattern = 'GitSignsUpdate',
        callback = function()
            lualine.refresh { place = { 'statusline' } }
        end,
    })

    lualine.setup {
        options = {
            icons_enabled = true,
            -- component_separators = { left = '', right = '' },
            component_separators = '',
            -- section_separators = { left = '', right = '' },
            section_separators = '',
            theme = 'auto',
            disabled_filetypes = {
                statusline = {},
                winbar = {},
            },
            ignore_focus = {},
            always_divide_middle = true,
            always_show_tabline = true,
            globalstatus = true,
            refresh = {
                statusline = 1000,
                tabline = 1000,
                winbar = 1000,
                refresh_time = 16, -- ~60fps
                events = {
                    'WinEnter',
                    'BufEnter',
                    'BufWritePost',
                    'SessionLoadPost',
                    'FileChangedShellPost',
                    'VimResized',
                    'Filetype',
                    'CursorMoved',
                    'CursorMovedI',
                    'ModeChanged',
                },
            }
        },
        sections = {
            lualine_a = {
                'mode',
            },
            lualine_b = {
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
            },
            lualine_c = {
            },
            lualine_x = {
                {
                    'branch',
                    icons_enabled = true,
                    icon = { '' },
                },
            },
            lualine_y = {
                -- 'encoding',
                -- 'filetype',
                'diagnostics',
                {
                    'diff',
                    icons_enabled = true,
                    colored = true, -- Displays a colored diff status if set to true
                    diff_color = {
                        added = 'GitSignsAdd',
                        modified = 'GitSignsChange',
                        removed = 'GitSignsDelete',
                    },
                    symbols = { added = '+', modified = '~', removed = '-' }, -- Changes the symbols used by the diff.
                    source = function()
                        local gs = vim.b.gitsigns_status_dict
                        if gs then
                            return {
                                added = gs.added,
                                modified = gs.changed,
                                removed = gs.removed,
                            }
                        end
                    end,
                    -- It must return a table as such:
                    --     { added = add_count, modified = modified_count, removed = removed_count }
                    -- or nil on failure. count <= 0 won"t be displayed.
                },
            },
            lualine_z = { 'progress' },
        },
        tabline = {
            lualine_a = {
                {
                    'buffers',
                    show_filename_only = true,      -- Shows shortened relative path when set to false.
                    hide_filename_extension = true, -- Hide filename extension when set to true.
                    show_modified_status = true,    -- Shows indicator when the buffer is modified.
                    max_length = vim.o.columns,
                    mode = 0,                       -- 0: Shows buffer name
                    filetype_names = {
                        TelescopePrompt = 'Telescope',
                        dashboard = 'Dashboard',
                        fzf = 'FZF',
                        alpha = 'Alpha',
                        NvimTree = 'NvimTree',
                        Term = 'Term',
                        oil = 'Oil',
                        iron = 'REPL',
                    },                      -- Shows specific buffer name for that filetype ( { `filetype` = `buffer_name`, ... } )
                    use_mode_colors = true, -- Automatically updates active buffer color to match color of other components
                    symbols = {
                        modified = ' ●',
                        alternate_file = false,
                        directory = '',
                    },
                    fmt = utils.shorten_filename,
                },
            },
            lualine_z = {},
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
