-- Undo tree as I'm too lazy for git repos everywhere
return {
    'mbbill/undotree',
    config = function()
        vim.g.undotree_WindowLayout = 2
        vim.g.undotree_ShortIndicators = 1
        vim.g.undotree_DiffAutoOpen = 0
        vim.g.undotree_DiffCommand = 'FC'
        vim.g.undotree_SetFocusWhenToggle = 1
        vim.g.undotree_HelpLine = 0
        vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = 'Toggle [U]ndotree' })
        vim.keymap.set('n', '<A-q>', function()
            local filetype = vim.bo.filetype
            if filetype == 'undotree' then
                vim.cmd 'UndotreeHide'
            else
                vim.cmd 'bdelete! | normal! zz'
            end
        end, { noremap = true, silent = true, desc = 'which_key_ignore' })
    end,
}
