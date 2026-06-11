-- Highlight, edit, and navigate code
vim.filetype.add { extension = { typ = 'typst' } }

local parsers = {
    'comment',
    'vimdoc',
    'vim',
    'lua',
    -- 'c',
    -- 'cpp',
    'python',
    -- 'nim',
    -- 'go',
    -- 'html',
    -- 'css',
    -- 'javascript',
    'sql',
    'yaml',
    'toml',
    'markdown',
    'markdown_inline',
    -- 'mermaid',
    -- 'latex', -- treesitter-cli required
    'typst',
    -- 'nu',
    'bash',
    'scheme',
}
for _, parser in ipairs(parsers) do
    vim.treesitter.language.add(parser, { path = vim.fn.expand('~/.local/share/nvim/site/parser/') .. parser .. '.so' })
end

return {}
