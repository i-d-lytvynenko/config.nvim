local function escape(str)
    -- Some characters require escaping
    local escape_chars = [[;,."|\]]
    return vim.fn.escape(str, escape_chars)
end

-- Recommended to use lua template string
-- local en = [[`qwertyuiop[]asdfghjkl;'zxcvbnm]]
-- local ru = [[ёйцукенгшщзхъфывапролджэячсмить]]
-- local en_shift = [[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>]]
-- local ru_shift = [[ËЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ]]

local en = [[`qwertyuiop[]asdfghjkl;'zxcvbnm,.]]
local ru = [[ёйцукенгшщзхъфывапролджэячсмитьбю]]
local en_shift = [[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>]]
local ru_shift = [[ËЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ]]

vim.opt.langmap = vim.fn.join({
    escape(ru_shift) .. ";" .. escape(en_shift),
    escape(ru) .. ";" .. escape(en),
}, ",")

vim.keymap.set("n", "Ё", "~", { desc = "which_key_ignore" })
vim.keymap.set("", "і", "s", { desc = "which_key_ignore" })
vim.keymap.set("", "І", "S", { desc = "which_key_ignore" })
vim.keymap.set("", "№", "#", { desc = "which_key_ignore" })
-- vim.keymap.set("", ";", "$", { desc = "which_key_ignore" })
vim.keymap.set("", "пБ", "g<", { desc = "which_key_ignore" })
vim.keymap.set("", "пВ", "gD", { desc = "which_key_ignore" })
vim.keymap.set("", "пУ", "gE", { desc = "which_key_ignore" })
vim.keymap.set("", "пР", "gH", { desc = "which_key_ignore" })
vim.keymap.set("", "пШ", "gI", { desc = "which_key_ignore" })
vim.keymap.set("", "пО", "gJ", { desc = "which_key_ignore" })
vim.keymap.set("", "пТ", "gN", { desc = "which_key_ignore" })
vim.keymap.set("", "пЗ", "gP", { desc = "which_key_ignore" })
vim.keymap.set("", "пЙ", "gQ", { desc = "which_key_ignore" })
vim.keymap.set("", "пК", "gR", { desc = "which_key_ignore" })
vim.keymap.set("", "пЕ", "gT", { desc = "which_key_ignore" })
vim.keymap.set("", "пГ", "gU", { desc = "which_key_ignore" })
vim.keymap.set("", "пМ", "gV", { desc = "which_key_ignore" })
vim.keymap.set("", "пъ", "g]", { desc = "which_key_ignore" })
vim.keymap.set("", "пф", "ga", { desc = "which_key_ignore" })
vim.keymap.set("", "пв", "gd", { desc = "which_key_ignore" })
vim.keymap.set("", "пу", "ge", { desc = "which_key_ignore" })
vim.keymap.set("", "па", "gf", { desc = "which_key_ignore" })
vim.keymap.set("", "пА", "gF", { desc = "which_key_ignore" })
vim.keymap.set("", "пп", "gg", { desc = "which_key_ignore" })
vim.keymap.set("", "пр", "gh", { desc = "which_key_ignore" })
vim.keymap.set("", "пш", "gi", { desc = "which_key_ignore" })
vim.keymap.set("", "по", "gj", { desc = "which_key_ignore" })
vim.keymap.set("", "пл", "gk", { desc = "which_key_ignore" })
vim.keymap.set("", "пт", "gn", { desc = "which_key_ignore" })
vim.keymap.set("", "пь", "gm", { desc = "which_key_ignore" })
vim.keymap.set("", "пщ", "go", { desc = "which_key_ignore" })
vim.keymap.set("", "пз", "gp", { desc = "which_key_ignore" })
vim.keymap.set("", "пй", "gq", { desc = "which_key_ignore" })
vim.keymap.set("", "пк", "gr", { desc = "which_key_ignore" })
vim.keymap.set("", "пы", "gs", { desc = "which_key_ignore" })
vim.keymap.set("", "пе", "gt", { desc = "which_key_ignore" })
vim.keymap.set("", "пг", "gu", { desc = "which_key_ignore" })
vim.keymap.set("", "пм", "gv", { desc = "which_key_ignore" })
vim.keymap.set("", "пц", "gw", { desc = "which_key_ignore" })
vim.keymap.set("", "пч", "gx", { desc = "which_key_ignore" })
vim.keymap.set("", "пЁ", "g~", { desc = "which_key_ignore" })
vim.cmd [[
    cabbrev <expr> ив	getcmdtype()==':' && getcmdline()=="ив"	? "bd"	: "ив"
    cabbrev <expr> ит	getcmdtype()==':' && getcmdline()=="ит"	? "bn"	: "ит"
    cabbrev <expr> й	getcmdtype()==':' && getcmdline()=="й"	? "q"	: "й"
    cabbrev <expr> йф	getcmdtype()==':' && getcmdline()=="йф"	? "qa"	: "йф"
    cabbrev <expr> ц	getcmdtype()==':' && getcmdline()=="ц"	? "w"	: "ц"
    cabbrev <expr> цй	getcmdtype()==':' && getcmdline()=="цй"	? "wq"	: "цй"
]]

local original_keymap = vim.keymap.set
local original_buffer_keymap = vim.api.nvim_buf_set_keymap

local function get_ru_variant(en_letter)
    local en_full = [[`qwertyuiop[]asdfghjkl;'zxcvbnm,.~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>]]
    local ru_full = [[ёйцукенгшщзхъфывапролджэячсмитьбюËЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ]]
    -- local en_full = [[`qwertyuiop[]asdfghjkl;'zxcvbnm~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>]]
    -- local ru_full = [[ёйцукенгшщзхъфывапролджэячсмитьËЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ]]
    for i = 1, #en_full do
        if en_full:sub(i, i) == en_letter then
            return ru_full:sub(i*2-1, i*2)
        end
    end
end

local function translate_keymap(str)
    local group_pairs = {
        alt_group = [[^<[aA]\-.>]],
        ctrl_group = [[^<[cC]\-.>]],
        shift_group = [[^<[sS]\-.>]],
        leader_group = [[\c^<leader>]],
        bs_group = [[\c^<bs>]],
        esc_group = [[\c^<esc>]],
        enter_group = [[\c^<cr>]],
        other_group = [[\c^<[ACS]\-\(tab\|cr\|space\|bs\|leader\)>]],
    }
    local regex_table = {
        alt_group = [[^<[aA]\-\zs.\ze>$]],
        ctrl_group = [[^<[cC]\-\zs.\ze>$]],
        shift_group = [[^<[sS]\-\zs.\ze>$]],
    }
    local start_i = 1
    local result = ""
    while true do
        local found_group
        for group_name, regex in pairs(group_pairs) do
            local match, match_start, match_end = unpack(vim.fn.matchstrpos(str, regex, start_i - 1))
            if match ~= "" then
                found_group = {
                    group_name = group_name,
                    match = match,
                    match_start = match_start,
                    match_end = match_end,
                }
                break
            end
        end
        if not found_group then
            local en_letter = str:sub(start_i, start_i)
            local ru_letter = get_ru_variant(en_letter)
            if not ru_letter then
                result = result .. en_letter
            else
                result = result .. ru_letter
            end
            start_i = start_i + 1
        elseif found_group.group_name == "ctrl_group" or found_group.group_name == "alt_group" then
            local symbol_regex = regex_table[found_group.group_name]
            local en_letter, _, letter_index = unpack(vim.fn.matchstrpos(found_group.match, symbol_regex))
            start_i = found_group.match_end + 1
            local ru_letter = get_ru_variant(en_letter:lower())
            local letter
            if not ru_letter then
                letter = en_letter
            else
                letter = ru_letter
            end
            result = result .. found_group.match:sub(1, letter_index - 1) .. letter .. found_group.match:sub(letter_index + 1)
        else
            result = result .. found_group.match
            start_i = found_group.match_end + 1
        end
        if start_i > #str then
            break
        end
    end
    return escape(result)
end

local keymap_set_wrapper = function(mode, lhs, rhs, opts)
    original_keymap(mode, lhs, rhs, opts)
    if not lhs:find("<Plug>") and #lhs:gsub('[\128-\191]', '') == #lhs then
        if type(opts) == "table" then
            opts.desc ="which_key_ignore"
        else
            opts = { desc = "which_key_ignore" }
        end
        original_keymap(mode, translate_keymap(lhs), rhs, opts)
    end
end

local buffer_keymap_set_wrapper = function(bufnr, mode, lhs, rhs, opts)
    original_buffer_keymap(bufnr, mode, lhs, rhs, opts)
    local i_not_mode = mode ~= "i" and not (type(mode) == "table" and mode:concat():match("i") ~= nil)
    local t_not_mode = mode ~= "t" and not (type(mode) == "table" and mode:concat():match("t") ~= nil)
    if not lhs:find("<Plug>") and #lhs:gsub('[\128-\191]', '') == #lhs and i_not_mode and t_not_mode then
        if type(opts) == "table" then
            opts.desc ="which_key_ignore"
        else
            opts = { desc = "which_key_ignore" }
        end
        original_buffer_keymap(bufnr, mode, translate_keymap(lhs), rhs, opts)
    end
end

vim.keymap.set = keymap_set_wrapper
vim.api.nvim_buf_set_keymap = buffer_keymap_set_wrapper
