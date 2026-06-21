-- Fix code formating for files
local config = function()
    local conform = require 'conform'

    local formatters = {}
    local formatters_by_ft = {
        lua = { 'stylua' },
        go = { 'gofumpt' },
        javascript = { 'prettierd', 'prettier' },
    }

    if vim.fn.isdirectory('/gnu/store') == 1 then
        formatters_by_ft.scheme = { 'guix_style' }
        formatters.guix_style = {
            command = 'guix',
            args = { 'style', '-f', '$FILENAME' },
            stdin = false,
        }
    end
    conform.setup {
        formatters_by_ft = formatters_by_ft,
        formatters = formatters,
    }
    vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
        conform.format {
            async = true,
            lsp_fallback = true,
        }
    end, { desc = '[F]ormat' })
end

return {
    'stevearc/conform.nvim',
    config = config,
}
