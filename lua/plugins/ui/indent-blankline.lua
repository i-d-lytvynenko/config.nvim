-- Add indentation guides even on blank lines
return {
    'lukas-reineke/indent-blankline.nvim',
    event = 'BufReadPre',
    main = 'ibl',
    opts = {
        indent = {
            -- char = '┊',
            char = '▏',
        },
        whitespace = {
            remove_blankline_trail = false,
        },
        scope = {
            enabled = true,
            show_start = false,
            show_end = false,
        },
    },
}
