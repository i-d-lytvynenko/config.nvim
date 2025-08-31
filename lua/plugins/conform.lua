local config = function()
    local conform = require 'conform'

    conform.setup {
        formatters_by_ft = {
            lua = { 'stylua' },
            go = { 'gofumpt' },
            javascript = { 'prettierd', 'prettier' },
        },
    }
    vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
        conform.format {
            async = true,
            lsp_fallback = true,
        }
    end, { desc = '[F]ormat' })
end

-- Fix code formating for files
return {
    'stevearc/conform.nvim',
    config = config,
}
