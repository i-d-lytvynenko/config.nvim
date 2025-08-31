-- Git blame support
return {
    'f-person/git-blame.nvim',
    event = 'VeryLazy',
    -- Because of the keys part, you will be lazy loading this plugin.
    -- The plugin will only load once one of the keys is used.
    -- If you want to load the plugin at startup, add something like event = 'VeryLazy',
    -- or lazy = false. One of both options will work.
    opts = {
        enabled = false,

        -- template for the blame message, check the Message template section for more options
        message_template = ' <summary> • <date> • <author> • <<sha>>',

        -- template for the date, check Date format section for more options
        date_format = '%m-%d-%Y %H:%M:%S',

        -- virtual text start column, check Start virtual text at column section for more options
        virtual_text_column = 1,
    },
    keys = {
        {
            'gt',
            [[<CMD>GitBlameToggle<CR><CMD>lua print('Git blame enabled:', vim.g.gitblame_enabled)<CR>]],
            desc = 'Toggle Git Blame',
        },
        {
            'gy',
            [[<CMD>GitBlameCopySHA<CR><CMD>lua print('SHA copied')<CR>]],
            desc = 'Copy SHA for current line',
        },
    },
}
