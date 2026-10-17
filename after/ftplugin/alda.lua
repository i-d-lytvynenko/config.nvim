-- Adds descriptions to vim-alda's buffer-local mappings so they show up readably in telescope.keymaps / which-key

local descs = {
    n = {
        ["<localleader>a"]  = "Alda: run CLI command",
        ["<localleader>s"]  = "Alda: parse buffer (score data)",
        ["<localleader>E"]  = "Alda: parse buffer (events)",
        ["<localleader>e"]  = "Alda: parse events (operator)",
        ["<localleader>ee"] = "Alda: parse events (line)",
        ["<localleader>p"]  = "Alda: play (operator)",
        ["<localleader>pp"] = "Alda: play line",
        ["<localleader>P"]  = "Alda: play buffer",
        ["<localleader>S"]  = "Alda: stop playback",
        ["<localleader>c"]  = "Alda: connect to REPL (port file)",
        ["<localleader>C"]  = "Alda: connect to REPL (enter port)",
        ["<localleader>d"]  = "Alda: disconnect from REPL",
        ["<localleader>n"]  = "Alda: new score (reset REPL state)",
        ["<localleader>t"]  = "Alda: show REPL score text",
        ["]]"]              = "Alda: next top-level block",
        ["[["]              = "Alda: previous top-level block",
        ["]["]              = "Alda: next instrument part",
        ["[]"]              = "Alda: previous instrument part",
    },
    v = {
        ["<localleader>p"] = "Alda: play selection",
        ["<localleader>e"] = "Alda: parse selection (events)",
    },
}

for mode, maps in pairs(descs) do
    for lhs, desc in pairs(maps) do
        local m = vim.fn.maparg(lhs, mode, false, true)
        if not vim.tbl_isempty(m) and m.buffer == 1 then
            m.desc = desc
            vim.fn.mapset(mode, false, m)
        end
    end
end
