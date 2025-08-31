local opts = { noremap = true, silent = true, desc = 'which_key_ignore' }

-- Set <space> as the leader key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', opts)
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Keep hands on home row
vim.keymap.set({ 'i', 'v' }, '<A-j><A-k>', '<Esc>', opts)
vim.keymap.set('t', '<A-j><A-k>', '<C-\\><C-n>', opts)

-- Jump to start or end of line (also replace $ on RU layout)
local function jump_line_start_end()
    local col = vim.fn.col '.'
    local last_col = vim.fn.col '$' - 1
    if col >= last_col or (col == last_col - 1 and vim.api.nvim_get_current_line():match '%a*[\128-\191]$') then
        vim.cmd 'normal! 0'
    else
        vim.cmd 'normal! $'
    end
end
vim.keymap.set({ 'n', 'v' }, '<A-z>', jump_line_start_end, opts)

-- Select last changed or yanked text
vim.keymap.set('n', 'gV', '`[v`]', opts)

-- Add empty lines from normal mode
vim.keymap.set('n', '<Leader>o', 'o<Esc>', opts)
vim.keymap.set('n', '<Leader>O', 'O<Esc>', opts)

-- Buffers
vim.keymap.set('n', '<A-n>', ':bnext<CR>zz', opts)
vim.keymap.set('n', '<A-p>', ':bprev<CR>zz', opts)
vim.keymap.set('n', 'Q', ':bdelete<CR>zz', opts)
vim.keymap.set('n', '<A-q>', ':bdelete!<CR>zz', opts)
vim.keymap.set({ 'i', 'v' }, '<A-q>', '<Esc>:bdelete!<CR>zz', opts)
vim.keymap.set('n', '<Leader>n', ':enew<CR>', opts)

-- Terminal
vim.keymap.set('n', '<leader>t', ':terminal<CR>i', opts)
vim.keymap.set('t', '<A-q>', '<C-\\><C-n>:bdelete!<CR>', opts)
vim.keymap.set('t', '<C-[>', '<C-\\><C-n>', opts)
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', opts)
vim.keymap.set('t', '<C-n>', '<Down>', opts)
vim.keymap.set('t', '<C-p>', '<Up>', opts)

-- Enter nushell normal mode
vim.keymap.set('t', '<A-i>', '<Esc>', opts)

-- Windows
vim.keymap.set('t', '<A-w>', '<C-\\><C-n><C-w>p', opts)
vim.keymap.set('t', '<A-f>', '<C-\\><C-n><C-w>oi', opts)
vim.keymap.set('n', '<A-w>', '<C-w>p', opts)
vim.keymap.set('n', '<A-f>', '<C-w>o', opts)
vim.keymap.set('n', '<A-v>', '<C-w>v', opts)
vim.keymap.set('n', '<A-s>', '<C-w>s', opts)
-- vim.keymap.set('n', '<A-h>', '<C-w>h', opts)
-- vim.keymap.set('n', '<A-j>', '<C-w>j', opts)
-- vim.keymap.set('n', '<A-k>', '<C-w>k', opts)
-- vim.keymap.set('n', '<A-l>', '<C-w>l', opts)

-- Exit to file tree
vim.keymap.set('n', '<leader>pv', ':edit.<CR>', opts)

-- Open URL without netrw
vim.keymap.set('n', 'gx', function()
    local url = string.match(vim.fn.expand '<cWORD>', '(https?://[a-zA-Z0-9_/%-%.~@\\+#=?&:]+)')
    if url then
        vim.cmd('Browse ' .. url)
    else
        print 'No https or http URI found on line'
    end
end, { desc = 'Open URL' })

-- Sessions
local session_path = vim.fn.stdpath 'config' .. '/session/mysession.vim'
function DeleteArgsAndSaveSession()
    if #vim.fn.argv() > 0 then
        vim.cmd ':argd*'
    end
    vim.cmd(':mksession! ' .. session_path)
end
vim.keymap.set('n', '<leader>ss', ":lua DeleteArgsAndSaveSession(); print('Session saved')<CR>", opts)
vim.keymap.set('n', '<leader>sl', ':silent! source ' .. session_path .. "<CR>:lua print('Session loaded')<CR>", opts)

-- Dragging selected text
vim.keymap.set('v', 'J', ":m '>+1<CR>gv", opts)
vim.keymap.set('v', 'K', ":m '<-2<CR>gv", opts)

-- Center cursor after jump
vim.keymap.set('n', 'J', 'mzJ`z', opts)
vim.keymap.set('n', '<C-o>', '<C-o>zz', opts)
vim.keymap.set('n', '<C-i>', '<C-i>zz', opts)
vim.keymap.set('n', '<C-d>', '15gjzz', opts)
vim.keymap.set('n', '<C-u>', '15gkzz', opts)
vim.keymap.set('n', 'n', 'nzzzv', opts)
vim.keymap.set('n', 'N', 'Nzzzv', opts)

-- Don't move cursor when gluing text with J
vim.keymap.set('n', 'J', 'mzJ`z', opts)

-- Keep search result always in the middle
vim.keymap.set('n', 'n', 'nzzzv', opts)
vim.keymap.set('n', 'N', 'Nzzzv', opts)

-- Fix word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Quickfix list
-- vim.keymap.set('n', '<leader>qq', '<cmd>copen<CR>zz', opts)
-- vim.keymap.set('n', '<leader>qk', '<cmd>cnext<CR>zz', opts)
-- vim.keymap.set('n', '<leader>qj', '<cmd>cprev<CR>zz', opts)

-- Locations list
-- vim.keymap.set('n', '<leader>ll', '<cmd>lopen<CR>zz', opts)
-- vim.keymap.set('n', '<leader>lk', '<cmd>lnext<CR>zz', opts)
-- vim.keymap.set('n', '<leader>lj', '<cmd>lprev<CR>zz', opts)

-- Diagnostic vim.keymap.sets
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- A paste mode that preserves the thing being copied in the buffer
vim.keymap.set('x', '<leader>p', [["_dP]], opts)

-- A delete mode that preserves the the thing in the buffer
vim.keymap.set({ 'n', 'v' }, '<leader>d', [["_d]], opts)

-- Add hotkeys for bookmarks
local status_ok, bookmarks = pcall(require, 'configs.bookmarks')
if status_ok then
    for key, path in pairs(bookmarks) do
        vim.keymap.set('n', '<leader>c' .. key, ':cd ' .. path .. '<CR>', { silent = false })
    end
end
-- Go to parent dir of current file
vim.keymap.set('n', '<leader>c<leader>', ':cd %:h<CR>', { silent = false })
