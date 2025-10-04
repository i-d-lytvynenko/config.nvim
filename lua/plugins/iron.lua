-- Python REPL
-- Use https://github.com/g0t4/dotfiles/blob/master/.config/nvim/lua/plugins/terminals.lua for reference
return {
    'Vigemus/iron.nvim',
    enabled = true,
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
        local iron = require 'iron.core'
        local view = require 'iron.view'
        local common = require 'iron.fts.common'
        local ll = require 'iron.lowlevel'

        local util = require 'lspconfig/util'
        local path = util.path
        local function get_ipython_path(workspace)
            for _, pattern in ipairs { '*', '.*' } do
                local match = vim.fn.glob(path.join(workspace, pattern, 'pyvenv.cfg'))
                if match ~= '' then
                    return path.join(path.dirname(match), 'Scripts', 'ipython.exe')
                end
            end
            return 'ipython'
        end

        -- INFO: the original code passed the dt table to chansend, which resulted in extra newlines.
        -- See: https://github.com/Vigemus/iron.nvim/issues/426
        ll.send_to_repl = function(meta, data)
            local dt = data

            if data == string.char(12) then
                vim.fn.chansend(meta.job, { string.char(12) })
                return
            end

            if type(data) == 'string' then
                dt = vim.split(data, '\n')
            end

            dt = require('iron.fts.common').format(meta.repldef, dt)

            local window = vim.fn.bufwinid(meta.bufnr)
            if window ~= -1 then
                vim.api.nvim_win_set_cursor(window, { vim.api.nvim_buf_line_count(meta.bufnr), 0 })
            end

            vim.fn.chansend(meta.job, table.concat(dt, '\n'))

            if window ~= -1 then
                vim.api.nvim_win_set_cursor(window, { vim.api.nvim_buf_line_count(meta.bufnr), 0 })
            end
        end

        local is_repl_window_open = function(ft)
            ft = ft or vim.bo.filetype
            if ft == nil or ft == '' then
                return false
            end

            local meta = ll.get(ft)
            if not ll.repl_exists(meta) then
                return false
            end

            local winid = vim.fn.bufwinid(meta.bufnr)
            if winid ~= -1 then
                return true
            end
            return false
        end

        iron.setup {
            config = {
                visibility = nil, -- keymaps already handle everything
                scratch_repl = true,
                buflisted = false,
                repl_definition = {
                    python = {
                        command = function(_)
                            local root_patterns = { '.git', 'pyproject.toml', 'requirements.txt', 'setup.py' }
                            local root_dir = vim.fs.root(vim.fn.getcwd(), root_patterns)
                            local ipython = get_ipython_path(root_dir)
                            return { ipython, '--no-autoindent' }
                        end,
                        format = function(lines, extras)
                            -- local result = common.bracketed_paste(lines, extras) -- everything selected is one cell
                            local result = common.bracketed_paste_python(lines, extras) -- cell per line

                            local filtered = {}
                            for _, line in ipairs(result) do
                                -- Trim trailing whitespace and carriage returns
                                local trimmed_line = string.gsub(line, '^(.-)%s*$', '%1')
                                trimmed_line = string.gsub(trimmed_line, '\r$', '')

                                -- Skip lines that are now empty after trimming
                                if trimmed_line == '' then
                                    goto continue
                                end

                                -- Skip lines that only contain a comment
                                if string.match(trimmed_line, '^%s*#') then
                                    goto continue
                                end

                                table.insert(filtered, trimmed_line)

                                ::continue::
                            end
                            table.insert(filtered, '\n')
                            return filtered
                        end,
                        block_dividers = { '# %%', '#%%' },
                        env = { PYTHON_BASIC_REPL = '1' }, --this is needed for python3.13 and up.
                    },
                },
                repl_filetype = function(_, ft)
                    return ft
                    -- or return a string name such as the following
                    -- return 'iron'
                    -- WARN: this will break toggle_repl
                end,
                dap_integration = true,
                repl_open_cmd = view.center(0.8, 0.8),
            },
            -- Iron doesn't set keymaps by default anymore.
            -- You can set them here or manually add keymaps to the functions in iron.core
            keymaps = {
                --- Unused keymaps (for now): ---

                -- cr = '<leader>i<cr>',
                -- send_motion = '<leader>is', -- + motion
                -- send_paragraph = '<leader>ip',

                -- send_code_block = '<leader>ib',
                -- send_code_block_and_move = '<leader>in',

                -- mark_motion = '<leader>imm',
                -- mark_visual = '<leader>imv',
                -- remove_mark = '<leader>imd',
                -- send_mark = '<leader>imr',
            },
            -- If the highlight is on, you can change how it looks
            -- For the available options, check nvim_set_hl
            highlight = {
                italic = true,
            },
            ignore_blank_lines = true,
        }

        -- REPL management
        vim.keymap.set('n', '<leader>ir', function()
            if is_repl_window_open() then
                vim.cmd 'IronHide'
            else
                vim.cmd 'IronFocus'
            end
        end, { desc = 'iron_toggle_repl' })
        vim.keymap.set('n', '<leader>iR', function()
            iron.repl_restart()
            vim.cmd 'IronHide'
        end, { desc = 'iron_restart_repl' })
        vim.keymap.set('n', '<leader>ic', function()
            vim.cmd 'IronHide'
            iron.send(nil, string.char(12))
        end, { desc = 'iron_clear' })
        vim.keymap.set('n', '<leader>ix', function()
            iron.send(nil, string.char(03))
            vim.cmd 'IronFocus'
        end, { desc = 'iron_interrupt' })
        vim.keymap.set('n', '<leader>iq', function()
            vim.cmd 'IronFocus'
            iron.close_repl()
        end, { desc = 'iron_quit' })

        -- Sending selected text
        vim.keymap.set('v', '<leader>iv', function()
            local meta = vim.b[0].repl
            local hide_new_repl = false
            if not ll.repl_exists(meta) then
                hide_new_repl = true
            end
            iron.visual_send()
            if hide_new_repl then
                vim.cmd 'IronHide'
            end
        end, { desc = 'iron_visual_send' })
        vim.keymap.set('n', '<leader>il', function()
            local meta = vim.b[0].repl
            local hide_new_repl = false
            if not ll.repl_exists(meta) then
                hide_new_repl = true
            end
            iron.send_line()
            if hide_new_repl then
                vim.cmd 'IronHide'
            end
        end, { desc = 'iron_send_line' })

        -- Sending chunks of files
        -- These functions require special treatment, because they internally rely on the active buffer,
        -- and you don't want to send the REPL history instead of your code by mistake
        vim.keymap.set('n', '<leader>if', function()
            vim.cmd 'IronHide'
            iron.send_file()
            vim.cmd 'IronFocus'
        end, { desc = 'iron_send_file' })
        vim.keymap.set('n', '<leader>iu', function()
            vim.cmd 'IronHide'
            iron.send_until_cursor()
            vim.cmd 'IronFocus'
        end, { desc = 'iron_send_until_cursor' })
    end,
}
