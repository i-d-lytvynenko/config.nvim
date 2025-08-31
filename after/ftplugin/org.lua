local checkbox_regex = [[^\_s*\zs\[[X -]\]\ze ]]
local checkbox_states = {
    ['[-]'] = '[X]',
    ['[ ]'] = '[X]',
    ['[X]'] = '[ ]',
}

local time_regex = '\\[\\d\\d[:]\\d\\d\\]'

local headline_regex = [[^\_s*\*\+\s.*]]
local headline_regex_template = [[^\_s*\*\+\s\(%s\)]]
local headline_link_regex = '{{\\(.\\{-}\\)}}'

local function clear_tasks()
    local mode = vim.fn.mode()
    local line_start, line_end
    if mode ~= 'n' then
        line_start = vim.fn.line 'v'
        line_end = vim.fn.line '.'
        if line_start > line_end then
            line_end, line_start = line_start, line_end
        end
    else
        line_start = vim.fn.line '.'
        line_end = line_start
    end

    local lines = vim.fn.getline(line_start, line_end)
    for i, line_content in ipairs(lines) do
        local line_number = i + line_start - 1
        local edited_line = line_content

        local cb_match, cb_start_index, cb_end_index = unpack(vim.fn.matchstrpos(line_content, checkbox_regex))
        if cb_match ~= '' then
            edited_line = edited_line:sub(1, cb_start_index) .. '[ ]' .. edited_line:sub(cb_end_index + 1)
        end

        local t_match, t_start_index, t_end_index = unpack(vim.fn.matchstrpos(line_content, time_regex))

        if t_match ~= '' and (cb_end_index + 1 == t_start_index or t_end_index == #line_content) then
            edited_line = edited_line:sub(1, t_start_index) .. edited_line:sub(t_end_index + 2)
        end

        if string.match(edited_line, '%s+') == edited_line then
            edited_line = ''
        end

        vim.api.nvim_buf_set_lines(0, line_number - 1, line_number, false, { edited_line })
    end
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n')
end

local function toggle_checkboxes(enable)
    local mode = vim.fn.mode()
    local line_start, line_end
    if mode ~= 'n' then
        line_start = vim.fn.line 'v'
        line_end = vim.fn.line '.'
        if line_start > line_end then
            line_end, line_start = line_start, line_end
        end
    else
        line_start = vim.fn.line '.'
        line_end = line_start
    end

    local lines = vim.fn.getline(line_start, line_end)
    for i, line_content in ipairs(lines) do
        local line_number = i + line_start - 1
        local match, start_index, end_index = unpack(vim.fn.matchstrpos(line_content, checkbox_regex))
        local new_state = checkbox_states[match]
        if enable then
            new_state = '[X]'
        elseif enable == false then
            new_state = '[ ]'
        end
        if new_state then
            local edited_line = line_content:sub(1, start_index) .. new_state .. line_content:sub(end_index + 1)
            vim.api.nvim_buf_set_lines(0, line_number - 1, line_number, false, { edited_line })
        end
    end
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n')
end

local function toggle_timer()
    local line_number = vim.fn.line '.'
    local line_content = vim.fn.getline(line_number)
    local timer_match, start_index, end_index = unpack(vim.fn.matchstrpos(line_content, time_regex))
    local current_time = '[' .. os.date '%H:%M' .. '] '
    if timer_match == '' then
        local checkbox_end_index = vim.fn.matchstrpos(line_content, checkbox_regex)[3]
        local exists_checkbox = checkbox_end_index ~= -1
        local line_whitespace = string.match(line_content, '%s*')
        if exists_checkbox then
            start_index = checkbox_end_index + 1
            end_index = start_index - 1
        else
            start_index = #line_whitespace
            end_index = start_index - 1
        end
    elseif timer_match .. ' ' == current_time then
        current_time = ''
    end
    local edited_line = line_content:sub(1, start_index) .. current_time .. line_content:sub(end_index + 2)
    vim.api.nvim_buf_set_lines(0, line_number - 1, line_number, false, { edited_line })
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n')
end

local function open_file_link()
    local filename = ''

    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 0-based indexing for column

    local open_bracket_idx, _ = string.find(line, '%[%[', 1)
    if open_bracket_idx ~= nil and open_bracket_idx <= col then
        local _, close_bracket_idx = string.find(line, '%]%]', open_bracket_idx + 2)
        if close_bracket_idx ~= nil and close_bracket_idx >= col then
            filename = string.sub(line, open_bracket_idx + 2, close_bracket_idx - 2)
        end
    end
    if filename == '' then
        print 'File not found.'
        return
    end

    local current_file_path = vim.fn.expand '%:p'
    local dirname = vim.fn.fnamemodify(current_file_path, ':h')
    local is_abs_path = (vim.fn.has 'win32' == 1 and (string.match(filename, '^[A-Z]:') ~= nil)) or (filename:sub(1, 1) == '/')
    if not is_abs_path then
        filename = dirname .. '/' .. filename
    end
    vim.cmd(('edit %s'):format(filename))
end

-- local function open_url()
--     local url = string.match(vim.fn.expand '<cWORD>', '(https?://[a-zA-Z0-9_/%-%.~@\\+#=?&:]+)')
--     if url then
--         vim.cmd('Browse ' .. url)
--     else
--         print 'No https or http URI found on line'
--     end
-- end

local function go_to_headline()
    local cursor_col = vim.api.nvim_win_get_cursor(0)[2]
    local current_line = vim.fn.getline '.'
    local start_i = 0
    local headline_name
    while true do
        local match, link_start, link_end = unpack(vim.fn.matchstrpos(current_line, headline_link_regex, start_i))
        if not link_start or match == '' then
            print 'No headline link found'
            return
        end
        if type(link_start) == 'string' then
            link_start = -1
        end
        if type(link_end) == 'string' then
            link_end = -1
        end
        if cursor_col >= link_start and cursor_col <= link_end then
            headline_name = match:sub(3, -3)
            break
        end
        if link_end ~= -1 then
            start_i = link_end
        else
            start_i = start_i + 1
        end
        if start_i > cursor_col then
            print 'No headline link found'
            return
        end
    end

    for line_i, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
        local match = vim.fn.matchstrpos(line, headline_regex)[1]
        if match ~= '' then
            local headline = vim.fn.matchstrpos(match, headline_regex_template:format(headline_name))[1]
            if headline ~= '' then
                vim.api.nvim_command "normal! m'"
                vim.api.nvim_win_set_cursor(0, { line_i, 0 })
                return
            end
        end
    end
    print 'No headline found'
end

local remaps = {
    { { 'n', 'v' }, '<A-c>', clear_tasks, { noremap = true, silent = true, desc = 'Clear selected tasks' } },
    { { 'n', 'v' }, '<A-b>', toggle_checkboxes, { noremap = true, silent = true, desc = 'Toggle checkboxes' } },
    { 'n', '<A-t>', toggle_timer, { noremap = true, silent = true, desc = 'Add time before a checkbox or update existing timer' } },
    { 'n', 'gf', open_file_link, { noremap = true, silent = true, desc = 'Open file link' } },
    -- { "n", "gx", open_url, { desc = "Open url in browser" } },
    { 'n', 'gl', go_to_headline, { desc = 'Go to headline' } },
}

for _, remap in ipairs(remaps) do
    local modes = remap[1]
    local lhs = remap[2]
    local rhs = remap[3]
    local remap_opts = remap[4] or {}
    remap_opts.buffer = 0
    vim.keymap.set(modes, lhs, rhs, remap_opts)
end
