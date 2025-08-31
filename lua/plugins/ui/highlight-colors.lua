-- Preview colors (#2599fa)
return {
    'brenoprata10/nvim-highlight-colors',
    event = 'BufReadPre',
    opts = {
        render = 'background', -- or "foreground" or "first_column"
        enable_named_colors = true,
        enable_tailwind = false,
    },
}
