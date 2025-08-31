-- Force yourself to use Nvim as intended
return {
    'm4xshen/hardtime.nvim',
    dependencies = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim' },
    opts = {
        showmode = false,
        disable_mouse = false,
        disabled_keys = {
            ['<Up>'] = {},
            ['<Down>'] = {},
            -- ['<Escape>'] = { 'i', 'v' },
        },
        max_time = 500,
        hints = {
            ['_i'] = {
                message = function()
                    return 'Use I instead of _i'
                end,
                length = 2,
            },
            ['%$a'] = {
                message = function()
                    return 'Use A instead of $a'
                end,
                length = 2,
            },
            ['[dcyvV][ia][%(%)]'] = {
                message = function(keys)
                    return 'Use ' .. keys:sub(1, 2) .. 'b instead of ' .. keys
                end,
                length = 3,
            },
        },
    },
}
