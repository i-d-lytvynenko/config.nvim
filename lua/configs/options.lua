local options = {
    hlsearch = false, -- set highlight on search
    number = true, -- set line numbers
    relativenumber = true, -- make line numbers relative
    guifont = { 'JetBrainsMono NFM:h14' }, -- change font (NFM patch is needed for icon support)
    mouse = 'a', -- enable mouse
    clipboard = 'unnamedplus', -- sync system clipboard
    breakindent = true, -- enable break indent
    undofile = true, -- save undo history
    ignorecase = true, -- case-insensitive searching
    smartcase = true, -- UNLESS \C or capital in search
    signcolumn = 'yes', -- keep signcolumn on by default
    tabstop = 4, -- insert 4 spaces for a tab
    shiftwidth = 4, -- the number of spaces inserted for each indentation
    expandtab = true, -- convert tabs to spaces
    smartindent = true, -- smart indent
    splitbelow = true, -- force all horizontal splits to go below current window
    splitright = true, -- force all vertical splits to go to the right of current window
    timeoutlen = 400, -- time to wait for a mapped sequence to complete (in milliseconds)
    updatetime = 250, -- faster completion (4000ms default)
    completeopt = { 'menuone', 'noselect' }, -- autocompletions config
    termguicolors = true, -- set term gui colors
    conceallevel = 0, -- show all symbols in files
    scrolloff = 8, -- minimal number of screen lines to keep above and below the cursor
    sidescrolloff = 8, -- minimal number of screen columns either side of cursor if wrap is `false`
    wrap = false, -- don't break long lines (for smooth scrolling)
    showmode = false, -- the mode is already shown in lualine
    foldmethod = 'indent', -- automatic indent folding with zf
    foldlevel = 99, -- unfold by default
    foldignore = '', -- disable ignoring lines starting with "#"
    -- foldcolumn = '1',  -- enable a 1-width foldcolumn to show lines with folded text
    -- fillchars = 'eob: ,fold: ,foldopen:,foldsep: ,foldclose:',  -- configure foldcolumn look
    viewoptions = 'folds,cursor', -- don't save current directory of a file to a view
    shell = 'nu', -- change default terminal
    shellcmdflag = '--stdin --table-mode markdown --no-newline -c', -- switch flags for nushell
    shelltemp = false, -- nu doesn't support input redirection, stdin will be used instead
    shellredir = 'out+err> %s', -- for diff-mode (nvim -d file1 file2) when diffopt is set
    shellslash = true, -- false breaks sending file to trash in nvim tree
    shellxescape = '',
    shellxquote = '',
    shellquote = '', -- disable command escaping and quoting
    cindent = true,
    cinkeys = [[0{,0},0),0],:,!^F,o,O,e]],
    indentkeys = [[0{,0},0),0],:,!^F,o,O,e]], -- fix indenting of lines that start with #
    winborder = 'rounded', -- add border to windows like docs
    title = true, -- Show filename in wezterm tab title
}

-- Don't load netrw on startup
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Fix markdown treesitter highlighting issues
vim.g.markdown_fenced_languages = {}

for k, v in pairs(options) do
    vim.opt[k] = v
end

-- Change UI language
vim.cmd 'language en_US'

-- Disable intro dashboard
vim.opt.shortmess:append { I = true }

-- Create custom Browse command for fugitive compatibility
vim.api.nvim_create_user_command('Browse', function(opts)
    -- vim.fn.system { 'cmd', '/c', 'start', opts.fargs[1] }
    vim.cmd('silent! !start ' .. opts.fargs[1])
end, { nargs = 1 })

-- Stop newline continuation of comments
vim.cmd [[autocmd BufNew,BufEnter * setlocal formatoptions-=cro]]

-- Keep folds state
vim.cmd [[
    augroup remember_folds
        autocmd!
        autocmd BufWinLeave * if filereadable(expand("%")) | mkview 1 | endif
        autocmd BufWinEnter * if filereadable(expand("%")) | silent! loadview 1 | endif
    augroup END
]]

-- Show relative line numbers in help files
vim.cmd [[autocmd FileType help setlocal relativenumber]]

-- Remove trailing whitespaces on save
vim.cmd [[autocmd BufWritePre * %s/\s\+$//e]]

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})

-- Fix command history for poetry venv
-- vim.cmd [[autocmd TermOpen * call chansend(b:terminal_job_id, "D:/projects/utils/buffer-fix/change_max_buffers.exe\r")]]

-- Enable soft wrapping for chosen filetypes
vim.cmd [[autocmd FileType markdown,text,org,plaintex,html,xml,mermaid,typst setlocal wrap]]

-- Set filetype of a new empty buffer to markdown
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    pattern = '{}',
    callback = function(args)
        if vim.api.nvim_buf_get_name(args.buf) == '' and vim.api.nvim_win_get_config(0).zindex == nil and vim.o.ft == '' then
            vim.o.ft = 'markdown'
        end
    end,
})

-- Set terminal filetype for lualine integration
vim.api.nvim_create_autocmd('TermOpen', {
    callback = function()
        vim.opt_local.filetype = 'Term'
    end,
})

-- Print tables
P = function(v)
    print(vim.inspect(v))
    return v
end

-- Redirect the output of a Vim or external command into current buffer
vim.cmd [[
function! Redir(cmd)
    if a:cmd =~ '^!'
        execute "let output = system('" . substitute(a:cmd, '^!', '', '') . "')"
    else
        redir => output
        execute a:cmd
        redir END
    endif
    let @z = trim(output)
    execute 'normal! "zp'
endfunction
command! -nargs=1 R silent call Redir(<f-args>)
]]

-- Preview and edit binary files with xxd
vim.cmd [[
    augroup Binary
        au!
        au BufReadPre  *.bin let &bin=1
        au BufReadPost *.bin if &bin | %!xxd
        au BufReadPost *.bin set ft=xxd | endif
        au BufWritePre *.bin if &bin | %!xxd -r
        au BufWritePre *.bin endif
        au BufWritePost *.bin if &bin | %!xxd
        au BufWritePost *.bin set nomod | endif
    augroup END
]]

vim.diagnostic.config { virtual_text = true, virtual_lines = false }

-- Nvim leaves a bunch of empty shada files on Windows
-- Fix waiting room: https://github.com/neovim/neovim/issues/8587
if vim.fn.has 'win32' == 1 then
    vim.api.nvim_create_autocmd('VimLeavePre', {
        callback = function()
            local shada_dir = vim.fn.stdpath 'data' .. '\\shada'
            local pattern = shada_dir .. '\\main.shada.tmp.*'
            for _, file in ipairs(vim.fn.glob(pattern, false, true)) do
                os.remove(file)
            end
        end,
    })
end
