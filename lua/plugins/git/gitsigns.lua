-- Adds git related signs to the gutter, as well as utilities for managing changes
return {
    'lewis6991/gitsigns.nvim',
    event = 'VimEnter',
    opts = {
        signs                        = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
        },
        signs_staged                 = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
        },
        signs_staged_enable          = true,
        signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
        numhl                        = true,  -- Toggle with `:Gitsigns toggle_numhl`
        linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir                 = {
            follow_files = true
        },
        auto_attach                  = true,
        attach_to_untracked          = false,
        current_line_blame           = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts      = {
            virt_text = true,
            virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
            delay = 1000,
            ignore_whitespace = false,
            virt_text_priority = 100,
            use_focus = true,
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        blame_formatter              = nil, -- Use default
        sign_priority                = 6,
        update_debounce              = 100,
        status_formatter             = nil,   -- Use default
        max_file_length              = 40000, -- Disable if file is longer than this (in lines)
        preview_config               = {
            -- Options passed to nvim_open_win
            style = 'minimal',
            relative = 'cursor',
            row = 0,
            col = 1
        },
        on_attach                    = function(bufnr)
            if vim.api.nvim_buf_get_name(bufnr):match '%.ipynb$' then
                -- Do not attach for .ipynb file, since these are converted
                -- with jupytext.nvim
                return false
            end
            local gitsigns = require('gitsigns')

            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr

                if opts.desc then
                    opts.desc = '<Gitsigns>: ' .. opts.desc
                end
                vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation
            map('n', ']c', function()
                if vim.wo.diff then
                    vim.cmd.normal({ ']c', bang = true })
                else
                    gitsigns.nav_hunk('next')
                end
            end, { desc = 'Next hunk' })

            map('n', '[c', function()
                if vim.wo.diff then
                    vim.cmd.normal({ '[c', bang = true })
                else
                    gitsigns.nav_hunk('prev')
                end
            end, { desc = 'Prev hunk' })

            -- Actions
            map('n', '<leader>hs', gitsigns.stage_hunk, { desc = '[S]tage hunk' })
            map('n', '<leader>hr', gitsigns.reset_hunk, { desc = '[R]eset hunk' })

            map('v', '<leader>hs', function()
                gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end, { desc = '[S]tage hunk' })

            map('v', '<leader>hr', function()
                gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end, { desc = '[R]eset hunk' })

            -- map('n', '<leader>hS', gitsigns.stage_buffer, {desc = '[S]tage buffer'})
            -- map('n', '<leader>hR', gitsigns.reset_buffer, {desc = '[R]eset buffer'})
            map('n', '<leader>hp', gitsigns.preview_hunk, { desc = '[P]review hunk' })
            -- map('n', '<leader>hi', gitsigns.preview_hunk_inline, {desc = 'Preview hunk [I]nline'})

            vim.keymap.set('n', '<leader>hb', function()
                gitsigns.blame_line({ full = false })
            end, { desc = '[B]lame line' })

            map('n', '<leader>hd', gitsigns.diffthis, { desc = '[D]iff side-by-side' })

            -- map('n', '<leader>hD', function()
            --     gitsigns.diffthis('~')
            -- end, {desc = '[D]iff side-by-side from last commit'})

            -- map('n', '<leader>hQ', function() gitsigns.setqflist('all') end, {desc = 'Populate [Q]uickfix list (???)'})
            -- map('n', '<leader>hq', gitsigns.setqflist, {desc = 'Populate [Q]uickfix list'})

            -- Toggles
            -- map('n', '<leader>tb', gitsigns.toggle_current_line_blame, {desc = '[T]oggle git [B]lame'})
            -- map('n', '<leader>tw', gitsigns.toggle_word_diff, {desc = '[T]oggle [W]ord diff'})

            -- Text object
            -- map({ 'o', 'x' }, 'ih', gitsigns.select_hunk)
        end,
    },
    config = function(_, opts)
        require('gitsigns').setup(opts)

        -- Enable soft wrap in the hunk preview popup and resize it to fit
        local popup = require('gitsigns.popup')
        local orig_create = popup.create
        popup.create = function(lines_spec, popup_opts, id)
            local winid, bufnr = orig_create(lines_spec, popup_opts, id)
            if id == 'hunk' then
                vim.wo[winid].wrap = true
                vim.wo[winid].linebreak = true
                popup.update(winid, bufnr, lines_spec, popup_opts)
            end
            return winid, bufnr
        end
    end,
}
