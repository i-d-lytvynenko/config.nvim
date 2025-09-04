-- Fuzzy Finder (files, LSP, etc)
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

    local nmap = function(keys, func, desc)
        if desc then
            desc = '<FZF>: ' .. desc
        end

        vim.keymap.set('n', keys, func, { desc = desc })
    end

    -- Enable telescope fzf native, if installed
    pcall(require('telescope').load_extension, 'fzf')
    local tls = require 'telescope.builtin'

    -- See `:help telescope.builtin`
    nmap('<leader>?', tls.oldfiles, '[?] Find recently opened files')
    nmap('<leader><space>', tls.buffers, '[ ] Find existing buffers')
    nmap('<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        tls.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
        })
    end, '[/] Fuzzily search in current buffer')

    nmap('<leader>gf', tls.git_files, 'Search [G]it [F]iles')
    nmap('<leader>sf', tls.find_files, '[S]earch [F]iles')
    nmap('<leader>sh', tls.help_tags, '[S]earch [H]elp')
    nmap('<leader>sw', tls.grep_string, '[S]earch current [W]ord')
    nmap('<leader>sg', tls.live_grep, '[S]earch by [G]rep')
    nmap('<leader>sd', tls.diagnostics, '[S]earch [D]iagnostics')
    nmap('<leader>sr', tls.resume, '[S]earch [R]esume')
    nmap('<leader>sq', tls.quickfix, '[S]earch [Q]uickfix list')
    nmap('<leader>st', tls.treesitter, '[S]earch [T]reesitter')
    nmap('<leader>sk', function()
        tls.keymaps {
            show_plug = false,
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
    end, '[S]earch [K]eymaps')
end

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
