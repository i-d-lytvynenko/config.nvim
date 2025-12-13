-- Autocompletion
local config = function()
    local cmp = require 'cmp'
    require('luasnip.loaders.from_vscode').lazy_load()

    cmp.setup {
        snippet = {
            expand = function(args)
                -- NOTE: use only one to prevent snippets triggering multiple times
                require('luasnip').lsp_expand(args.body)
            end,
        },
        window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert {
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            ['<CR>'] = cmp.mapping.confirm { select = true },
        },
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
        }, {
            { name = 'buffer' },
        }),
    }

    cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
            { name = 'git' },
        }, {
            { name = 'buffer' },
        }),
    })
    require('cmp_git').setup()

    -- https://github.com/hrsh7th/nvim-cmp/issues/874#issuecomment-2181591457
    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({ '/', '?' }, {
        -- mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = 'buffer' },
        },
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(':', {
        -- mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = 'path' },
        }, {
            { name = 'cmdline' },
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
    })
end
return {
    'hrsh7th/nvim-cmp',
    config = config,
    event = 'VimEnter',
    dependencies = {
        'hrsh7th/cmp-buffer', -- Completion source for text in current buffer
        'hrsh7th/cmp-path', -- Completion source for file paths
        'hrsh7th/cmp-nvim-lsp', -- Enables completion from LSP servers
        'hrsh7th/cmp-nvim-lsp-signature-help', -- Adds signature help (function arguments) in completion popups
        {
            'L3MON4D3/LuaSnip', -- Snippet engine for Lua
            version = 'v2.*',
            build = 'make install_jsregexp', -- Advances snippet matching
            dependencies = {
                'saadparwaiz1/cmp_luasnip', -- Integration between nvim-cmp and LuaSnip
                'rafamadriz/friendly-snippets', -- Collection of pre-defined snippets
            },
        },
        'onsails/lspkind.nvim', -- Adds icons to completion items for better visual context
        'petertriho/cmp-git', -- Git support
    },
}
