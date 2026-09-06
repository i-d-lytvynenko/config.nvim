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
        -- If you don't want to install the "emacs-minimal" package,
        -- you can use this, but it resolves '\n' in the code into actual newlines:
        -- formatters_by_ft.scheme = { 'guix_style' }
        -- formatters.guix_style = {
        --     command = 'guix',
        --     args = { 'style', '-f', '$FILENAME' },
        --     stdin = false,
        -- }
        formatters_by_ft.scheme = { 'emacs_scheme' }
        formatters.emacs_scheme = {
            command = 'emacs',
            args = {
                '--batch',
                '$FILENAME',
                '--eval',
                '(setq make-backup-files nil)',
                '--eval',
                '(indent-region (point-min) (point-max))',
                '-f',
                'save-buffer'
            },
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
