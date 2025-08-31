local config = function()
    -- Default compiler has troubles with orgmode and probably something else
    require('nvim-treesitter.install').compilers = { 'zig' }

    vim.filetype.add { extension = { typ = 'typst' } }

    require('nvim-treesitter.configs').setup {
        modules = {},
        ignore_install = {},
        ensure_installed = {
            'comment',
            'vimdoc',
            'vim',
            'lua',
            'c',
            'cpp',
            'python',
            'nim',
            'go',
            'html',
            'css',
            'javascript',
            'sql',
            'yaml',
            'toml',
            'markdown',
            'markdown_inline',
            'mermaid',
            'latex', -- treesitter-cli required (?)
            'typst',
            'nu',
            'bash',
        },

        -- Autoinstall languages that are not installed
        auto_install = false,
        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        highlight = { enable = true },
        -- indent = { enable = true },
        -- incremental_selection = {
        --     enable = true,
        --     keymaps = {
        --         init_selection = '<c-space>',
        --         node_incremental = '<c-space>',
        --         scope_incremental = '<c-s>',
        --         node_decremental = '<M-space>',
        --     },
        -- },
        textobjects = {
            select = {
                enable = true,
                lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ['aa'] = '@parameter.outer',
                    ['ia'] = '@parameter.inner',
                    ['af'] = '@function.outer',
                    ['if'] = '@function.inner',
                    ['ac'] = '@class.outer',
                    ['ic'] = '@class.inner',
                },
            },
            move = {
                enable = true,
                set_jumps = true, -- whether to set jumps in the jumplist
                goto_next_start = {
                    [']m'] = '@function.outer',
                    [']]'] = '@class.outer',
                },
                goto_next_end = {
                    [']M'] = '@function.outer',
                    [']['] = '@class.outer',
                },
                goto_previous_start = {
                    ['[m'] = '@function.outer',
                    ['[['] = '@class.outer',
                },
                goto_previous_end = {
                    ['[M'] = '@function.outer',
                    ['[]'] = '@class.outer',
                },
            },
            swap = {
                enable = true,
                swap_next = {
                    ['<leader>a'] = '@parameter.inner',
                },
                swap_previous = {
                    ['<leader>A'] = '@parameter.inner',
                },
            },
        },
    }
end

-- Highlight, edit, and navigate code
return {
    'nvim-treesitter/nvim-treesitter',
    config = config,
    event = 'VeryLazy',
    dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
}
