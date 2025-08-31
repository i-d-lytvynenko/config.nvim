local config = function()
    require('telescope').setup {
        defaults = {
            mappings = {
                i = {
                    ['<C-u>'] = false,
                    ['<C-d>'] = false,
                    ['<A-q>'] = require('telescope.actions').close,
                },
            },
        },
    }

    -- Enable telescope fzf native, if installed
    pcall(require('telescope').load_extension, 'fzf')
    local tls = require 'telescope.builtin'

    -- See `:help telescope.builtin`
    vim.keymap.set('n', '<leader>?', tls.oldfiles, { desc = '[?] Find recently opened files' })
    vim.keymap.set('n', '<leader><space>', tls.buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        tls.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
        })
    end, { desc = '[/] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<leader>gf', tls.git_files, { desc = 'Search [G]it [F]iles' })
    vim.keymap.set('n', '<leader>sf', tls.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sh', tls.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sw', tls.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', tls.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', tls.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', tls.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>sq', tls.quickfix, { desc = '[S]earch [Q]uickfix list' })
    vim.keymap.set('n', '<leader>st', tls.treesitter, { desc = '[S]earch [T]reesitter' })
    vim.keymap.set('n', '<leader>sk', function()
        tls.keymaps {
            filter = function(keymap)
                if keymap.desc ~= 'which_key_ignore' then
                    return true
                end
                if #keymap.desc == 0 then
                    return true
                end
                if string.match(keymap.desc, '^%d') ~= nil then
                    return true
                end
                return false
            end,
        }
    end, { desc = '[S]earch [K]eymaps' })
end

-- Fuzzy Finder (files, LSP, etc)
return {
    'nvim-telescope/telescope.nvim',
    config = config,
    event = 'VimEnter',
    dependencies = {
        'nvim-lua/plenary.nvim',
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
            cond = function()
                return vim.fn.executable 'make' == 1
            end,
        },
    },
}
