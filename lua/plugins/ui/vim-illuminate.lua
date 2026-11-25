-- Highlighting other uses of the word under the cursor using either LSP, Tree-sitter, or regex matching
return {
    'RRethy/vim-illuminate',
    config = function()
        require('illuminate').configure {
            -- providers: provider used to get references in the buffer, ordered by priority
            providers = {
                'treesitter',
                'regex',
                'lsp',
            },
            -- delay: delay in milliseconds
            delay = 0,
            -- filetype_overrides: filetype specific overrides.
            -- The keys are strings to represent the filetype while the values are tables that
            -- supports the same keys passed to .configure except for filetypes_denylist and filetypes_allowlist
            filetype_overrides = {},
            -- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
            filetypes_denylist = {
                'dirbuf',
                'dirvish',
                'fugitive',

                'text',
                'markdown',
                'org',
                'help',

                'TelescopePrompt',
                'dashboard',
                'fzf',
                'alpha',
                'NvimTree',
                'Term',
                'oil',
                'floggraph',
            },
            -- filetypes_allowlist: filetypes to illuminate, this is overridden by filetypes_denylist
            -- You must set filetypes_denylist = {} to override the defaults to allow filetypes_allowlist to take effect
            filetypes_allowlist = {},
            -- modes_denylist: modes to not illuminate, this overrides modes_allowlist
            -- See `:help mode()` for possible values
            modes_denylist = {},
            -- modes_allowlist: modes to illuminate, this is overridden by modes_denylist
            -- See `:help mode()` for possible values
            modes_allowlist = {},
            -- providers_regex_syntax_denylist: syntax to not illuminate, this overrides providers_regex_syntax_allowlist
            -- Only applies to the 'regex' provider
            -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
            providers_regex_syntax_denylist = {},
            -- providers_regex_syntax_allowlist: syntax to illuminate, this is overridden by providers_regex_syntax_denylist
            -- Only applies to the 'regex' provider
            -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
            providers_regex_syntax_allowlist = {},
            -- under_cursor: whether or not to illuminate under the cursor
            under_cursor = true,
            -- large_file_cutoff: number of lines at which to use large_file_config
            -- The `under_cursor` option is disabled when this cutoff is hit
            large_file_cutoff = 10000,
            -- large_file_config: config to use for large files (based on large_file_cutoff).
            -- Supports the same keys passed to .configure
            -- If nil, vim-illuminate will be disabled for large files.
            large_file_overrides = nil,
            -- min_count_to_highlight: minimum number of matches required to perform highlighting
            min_count_to_highlight = 1,
            -- should_enable: a callback that overrides all other settings to
            -- enable/disable illumination. This will be called a lot so don't do
            -- anything expensive in it.
            should_enable = function(bufnr)
                return true
            end,
            -- case_insensitive_regex: sets regex case sensitivity
            case_insensitive_regex = false,
            -- disable_keymaps: disable default keymaps
            disable_keymaps = false,
        }

        -- Illuminate only highlights within the current buffer;
        -- mirror the word under the cursor into all other windows of the tab via window-local matches
        local match_ids = {} -- winid -> match id

        local function clear_matches()
            for win, id in pairs(match_ids) do
                if vim.api.nvim_win_is_valid(win) then
                    pcall(vim.fn.matchdelete, id, win)
                end
            end
            match_ids = {}
        end

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'WinEnter', 'BufEnter' }, {
            group = vim.api.nvim_create_augroup('illuminate_other_windows', { clear = true }),
            callback = function()
                clear_matches()
                -- <cword> falls forward to the next word when the cursor isn't on a keyword char
                local col = vim.api.nvim_win_get_cursor(0)[2]
                local char = vim.api.nvim_get_current_line():sub(col + 1, col + 1)
                if char == '' or vim.fn.match(char, '\\k') ~= 0 then
                    return
                end
                local word = vim.fn.expand('<cword>')
                if not word:match('^[%w_]+$') then
                    return
                end
                local pattern = '\\V\\<' .. word .. '\\>'
                local cur_win = vim.api.nvim_get_current_win()
                local cur_buf = vim.api.nvim_get_current_buf()
                for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                    -- skip the current window, floats, and windows on the same buffer (illuminate covers those)
                    if
                        win ~= cur_win
                        and vim.api.nvim_win_get_buf(win) ~= cur_buf
                        and vim.api.nvim_win_get_config(win).relative == ''
                    then
                        match_ids[win] = vim.fn.matchadd('IlluminatedWordText', pattern, 10, -1, { window = win })
                    end
                end
            end,
        })
    end,
}
