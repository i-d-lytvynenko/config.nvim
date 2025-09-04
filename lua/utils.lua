local M = {}
local sep = '\\'

local split_path = function(path)
    local separators = { '/', '\\', ':', '\\\\' }
    local pattern = table.concat(separators, '')
    local normalized_path = path:gsub('[' .. pattern .. ']', sep)
    return vim.split(normalized_path, sep)
end

local lowercase_disk_name = function(path)
    local firstChar = string.sub(path, 1, 1)
    local charCode = string.byte(firstChar)

    -- Check if it's an uppercase letter (A-Z)
    if charCode >= 65 and charCode <= 90 then
        -- Convert to lowercase by adding 32 to the ASCII value
        local lowercaseCharCode = charCode + 32
        local lowercaseChar = string.char(lowercaseCharCode)
        return lowercaseChar .. string.sub(path, 2)
    else
        return path
    end
end

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

    local segments = split_path(path)

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

M.get_relative_path = function(from_path, to_path)
    from_path = lowercase_disk_name(from_path)
    to_path = lowercase_disk_name(to_path)
    local from_segments = split_path(from_path)
    local to_segments = split_path(to_path)

    local common_prefix_length = 0
    for i = 1, math.min(#from_segments, #to_segments) do
        if from_segments[i] == to_segments[i] then
            common_prefix_length = i
        else
            break
        end
    end

    local relative_segments = {}
    local num_ups = (#from_segments - common_prefix_length - 1)
    for _ = 1, num_ups do
        table.insert(relative_segments, '..')
    end

    for i = common_prefix_length + 1, #to_segments do
        table.insert(relative_segments, to_segments[i])
    end

    if #relative_segments == 0 then
        return from_segments[#from_segments]
    end
    return table.concat(relative_segments, '/')
end

return M
