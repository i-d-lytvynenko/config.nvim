-- Git branch viewer
local config = function()
    vim.g.flog_num_branch_colors = 32
    vim.g.flog_permanent_default_opts = { date = 'short', all = true }
    vim.keymap.set('n', 'gh', ':Flog<CR>', { desc = 'Open git history (full branch view)', noremap = true })
    vim.keymap.set('n', 'gH', '', { noremap = true, silent = true }) -- remove select mode
    vim.keymap.set('n', 'ghh', ':Flog -raw-args=--simplify-by-decoration<CR>', { desc = 'Open git history (simple branch view)', noremap = true })
end

return {
    'rbong/vim-flog',
    lazy = false,
    cmd = { 'Flog', 'Flogsplit', 'Floggit' },
    dependencies = {
        'tpope/vim-fugitive',
    },
    config = config,
}
