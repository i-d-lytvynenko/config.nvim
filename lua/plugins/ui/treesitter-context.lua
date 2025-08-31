-- TreesitterContextMeta = {
--     idle_time = 200,
--     post_idle_time = 200,
--     timer = vim.loop.new_timer(),
--     post_timer = vim.loop.new_timer(),
--     max_line_diff = 2,
--     post_stop_diff = 2,
--     timer_started = false,
--     enabled = false,
-- }

-- function ShowTreesitterContext()
--     local current_line = vim.fn.line '.'
--     if TreesitterContextMeta.timer_started then
--         return
--     end
--     local delay_show
--     delay_show = function()
--         local prev_line = current_line
--         current_line = vim.fn.line '.'
--         if math.abs(prev_line - current_line) <= TreesitterContextMeta.max_line_diff then
--             _ = not TreesitterContextMeta.enabled and vim.cmd 'TSContextEnable'
--             TreesitterContextMeta.enabled = true
--         else
--             _ = TreesitterContextMeta.enabled and vim.cmd 'TSContextDisable'
--             TreesitterContextMeta.enabled = false
--             TreesitterContextMeta.post_timer:stop()
--             TreesitterContextMeta.post_timer:start(
--                 TreesitterContextMeta.post_idle_time,
--                 0,
--                 vim.schedule_wrap(function()
--                     prev_line = current_line
--                     current_line = vim.fn.line '.'
--                     if math.abs(prev_line - current_line) <= TreesitterContextMeta.post_stop_diff then
--                         _ = not TreesitterContextMeta.enabled and vim.cmd 'TSContextEnable'
--                         TreesitterContextMeta.enabled = true
--                     end
--                     TreesitterContextMeta.post_timer:stop()
--                 end)
--             )
--         end
--         TreesitterContextMeta.timer:stop()
--         TreesitterContextMeta.timer_started = false
--     end
--     TreesitterContextMeta.timer_started = true
--     TreesitterContextMeta.timer:start(TreesitterContextMeta.idle_time, 0, vim.schedule_wrap(delay_show))
-- end

-- local config = function()
--     vim.cmd [[
--         augroup IdleAutocmd
--         autocmd!
--         autocmd CursorHold * lua ShowTreesitterContext()
--         autocmd CursorMoved * lua ShowTreesitterContext()
--         augroup END
--     ]]
-- end

-- -- Show context of cursor
-- return {
--     'nvim-treesitter/nvim-treesitter-context',
--     event = 'BufReadPre',
--     config = config,
--     opts = {
--         enable = false,
--         max_lines = 5, -- How many lines the window should span. Values <= 0 mean no limit.
--         multiline_threshold = 1, -- Maximum number of lines to show for a single context
--     },
-- }

-- Show context of cursor
return {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'BufReadPre',
    opts = {
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
        multiwindow = false, -- Enable multiwindow support.
        max_lines = 5, -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 1, -- Maximum number of lines to show for a single context
        trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20, -- The Z-index of the context window
        on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    },
}
