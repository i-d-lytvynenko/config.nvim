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
        -- local ll = require 'iron.lowlevel'
        local visibility = require 'iron.visibility'

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

        iron.setup {
            config = {
                scratch_repl = true,
                -- Triggers when the window is already open
                -- visibility = visibility.focus,
                -- visibility = function(bufid, showfn)
                --     -- Using `single` is a workaround to access the state of repl window
                --     local window, was_hidden = visibility.single(bufid, showfn)
                --     -- vim.api.nvim_set_current_win(window)
                --     print(window, was_hidden)
                --     -- if was_hidden then
                --     -- else
                --     --     vim.api.nvim_win_hide(window)
                --     -- end
                -- end,
                buflisted = true,
                repl_definition = {
                    python = {
                        command = function(_)
                            -- TODO: find root directory (contains requirements.txt, .git or pyproject.toml)
                            local root_dir = vim.fn.getcwd()
                            local ipython = get_ipython_path(root_dir)
                            return { ipython, '--no-autoindent' }
                        end,
                        format = function(lines, extras)
                            -- result = common.bracketed_paste(lines, extras) -- everything selected is one cell
                            local result = common.bracketed_paste_python(lines, extras) -- cell per line

                            -- Remove lines that only contain a comment
                            local filtered = vim.tbl_filter(function(line)
                                return not string.match(line, '^%s*#')
                            end, result)
                            return filtered
                        end,
                        block_dividers = { '# %%', '#%%' },
                        env = { PYTHON_BASIC_REPL = '1' }, --this is needed for python3.13 and up.
                    },
                },
                -- set the file type of the newly created repl to ft
                -- bufnr is the buffer id of the REPL and ft is the filetype of the
                -- language being used for the REPL.
                repl_filetype = function()
                    return 'iron'
                end,
                dap_integration = true,
                repl_open_cmd = view.center(0.8, 0.8),
            },
            -- Iron doesn't set keymaps by default anymore.
            -- You can set them here or manually add keymaps to the functions in iron.core
            keymaps = {
                -- toggle_repl = '<leader>ir',
                restart_repl = '<leader>iR',

                send_motion = '<leader>is', -- + motion
                visual_send = '<leader>iv',
                send_file = '<leader>if',
                send_line = '<leader>il',
                -- send_paragraph = '<leader>ip',
                -- send_until_cursor = '<leader>iu',

                send_code_block = '<leader>ib',
                send_code_block_and_move = '<leader>in',

                -- mark_motion = '<leader>imm',
                -- mark_visual = '<leader>imv',
                -- remove_mark = '<leader>imd',
                -- send_mark = '<leader>imr',

                cr = '<leader>i<cr>',
                interrupt = '<leader>ix',
                exit = '<leader>iq',
                clear = '<leader>ic',
            },
            -- If the highlight is on, you can change how it looks
            -- For the available options, check nvim_set_hl
            highlight = {
                italic = true,
            },
            ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
        }

        vim.keymap.set('n', '<leader>ir', '<cmd>IronReplHere<cr>i')
    end,
}
