local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
            { out, 'WarningMsg' },
            { '\nPress any key to exit...' },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup {
    spec = {
        { import = 'plugins' },
        { import = 'plugins.git' },
        { import = 'plugins.qol' },
        { import = 'plugins.ui' },
        { import = 'plugins.other' },
    },
    install = {
        colorscheme = { 'onedark_dark' },
    },
    change_detection = { notify = false },
    dev = {
        path = 'F:/IT/nvim_plugins',
        fallback = false, -- Fallback to git when local plugin doesn't exist
    },
    rocks = {
        hererocks = false,
        enabled = false,
    },
}
