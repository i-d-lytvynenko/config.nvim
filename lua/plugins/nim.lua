vim.cmd [[
    augroup nimf_html_highlight
        autocmd!
        autocmd BufRead,BufNewFile *.nhtml set filetype=html
    augroup END
]]

-- Nim template support
return {}
