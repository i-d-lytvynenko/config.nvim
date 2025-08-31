-- Open .ipynb in Neovim
vim.g.jupytext_command = 'use conda.nu; conda activate ds; jupytext'

return {
    'goerz/jupytext.vim',
    -- 'GCBallesteros/jupytext.nvim',
    -- config = true,
    -- lazy = false,
}
