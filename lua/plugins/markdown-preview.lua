local config = function()
    vim.g.mkdp_page_title = 'Preview: ${name}'
    vim.g.mkdp_port = '1770'
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_filetypes = { 'markdown', 'mermaid' }
end

-- Open markdown preview in browser window
return {
    'iamcco/markdown-preview.nvim',
    ft = { 'markdown', 'pandoc.markdown', 'rmd', 'mermaid' },
    keys = {
        { '<A-b>', ':MarkdownPreviewToggle<CR>', ft = { 'markdown', 'mermaid' } },
    },
    build = 'cd app && yarn install',
    config = config,
}
