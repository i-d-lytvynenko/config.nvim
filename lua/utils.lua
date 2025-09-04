local M = {}

M.shorten_filename = function(filename, opts)
    opts = opts or {}
    local max_length = vim.F.if_nil(opts.max_length, 20)

    local dot_index = filename:find('%.[^%.]*$', 1)
    local base_name, extension
    if dot_index then
        base_name = filename:sub(1, dot_index - 1)
        extension = filename:sub(dot_index)
    else
        base_name = filename
        extension = ''
    end
    local current_length = vim.fn.strdisplaywidth(base_name)

    if current_length > max_length then
        base_name = vim.fn.strcharpart(base_name, 0, max_length) .. '..'
        if extension == '' then
            base_name = base_name .. '.'
        end
    end

    return base_name .. extension
end

M.shorten_file_path = function(opts)
    opts = opts or {}
    local max_length = vim.F.if_nil(opts.max_length, 30)
    local path = vim.F.if_nil(opts.path, vim.fn.expand '%:~:.')

    local len = vim.fn.strdisplaywidth(path)
    if len <= max_length then
        return path
    end

    local sep = '\\'
    local separators = { '/', '\\', ':', '\\\\' }
    local pattern = table.concat(separators, '')
    local normalized_path = path:gsub('[' .. pattern .. ']', sep)
    local segments = vim.split(normalized_path, sep)
    for idx = 1, #segments - 1 do
        if len <= max_length then
            break
        end

        local segment = segments[idx]
        local shortened = vim.fn.strcharpart(segment, 0, vim.startswith(segment, '.') and 2 or 1)
        segments[idx] = shortened
        len = len - (vim.fn.strdisplaywidth(segment) - vim.fn.strdisplaywidth(shortened))
    end
    segments[#segments] = M.shorten_filename(segments[#segments])

    return table.concat(segments, sep)
end

return M
