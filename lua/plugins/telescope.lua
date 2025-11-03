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
        pickers = {
            lsp_references = {
                -- Telescope can't show relative paths with LSP symbols
                -- See https://github.com/nvim-telescope/telescope.nvim/issues/2906
                path_display = function(opts, path)
                    return require('utils').get_relative_path(opts.curr_filepath, path)
                end,
            },
            diagnostics = {
                entry_maker = function(entry)
                    entry.filename = require('utils').get_relative_path(vim.fn.getcwd(), entry.filename)
                    return require('telescope.make_entry').gen_from_diagnostics()(entry)
                end,
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
    nmap('<leader>sr', tls.resume, '[S]earch [R]esume')

    nmap('<leader>sf', tls.find_files, '[S]earch [F]iles')
    nmap('<leader>sg', tls.live_grep, '[S]earch by [G]rep')

    nmap('<leader>st', tls.treesitter, '[S]earch [T]reesitter')
    nmap('<leader>sp', tls.lsp_document_symbols, '[S]earch LS[P] Document Symbols')
    nmap('<leader>sd', tls.diagnostics, '[S]earch [D]iagnostics')

    nmap('<leader>sq', tls.quickfix, '[S]earch [Q]uickfix list')
    nmap('<leader>sh', tls.help_tags, '[S]earch [H]elp')
    nmap('<leader>sc', tls.commands, '[S]earch [C]ommands')
    nmap('<leader>sk', function()
        tls.keymaps {
            show_plug = false,
            filter = function(keymap)
                if keymap.desc == 'which_key_ignore' then
                    return false
                end
                if keymap.desc == nil or #keymap.desc == 0 then
                    return false
                end
                if string.match(keymap.desc, '^%d') ~= nil then
                    return false
                end
                return true
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
