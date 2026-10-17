-- Adds descriptions to vim-alda's buffer-local mappings so they show up readably in telescope.keymaps / which-key

-- Mappings defined in this file. Edit here to rebind; the plugin's own
-- mappings for these keys get overwritten.
local keys = {
    hard_stop    = "<localleader>s", -- plugin default: <localleader>S
    parse_data   = "<localleader>S", -- plugin default: <localleader>s
    parse_events = "<localleader>E",
    reset        = "<localleader>R",
}

local descs = {
    n = {
        ["<localleader>a"]  = "Alda: run CLI command",
        ["<localleader>e"]  = "Alda: parse events (operator)",
        ["<localleader>ee"] = "Alda: parse events (line)",
        ["<localleader>p"]  = "Alda: play (operator)",
        ["<localleader>pp"] = "Alda: play line",
        ["<localleader>P"]  = "Alda: play buffer",
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

-- Deferred: with lazy-loading (ft = "alda") the plugin's mappings appear
-- only after this file has run, so we wait until all ftplugins are done.
local buf = vim.api.nvim_get_current_buf()

vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    vim.api.nvim_buf_call(buf, function()
        for mode, maps in pairs(descs) do
            for lhs, desc in pairs(maps) do
                local m = vim.fn.maparg(lhs, mode, false, true)
                if not vim.tbl_isempty(m) and m.buffer == 1 then
                    -- <SID> must point at the plugin's script, not at this file
                    local rhs = m.rhs:gsub("<SID>", "<SNR>" .. m.sid .. "_")
                    vim.keymap.set(mode, lhs, rhs, {
                        buffer = buf,
                        desc = desc,
                        remap = m.noremap == 0,
                        silent = m.silent == 1,
                        nowait = m.nowait == 1,
                        expr = m.expr == 1,
                    })
                end
            end
        end
    end)
end)

-- ── Hard stop ─────────────────────────────────────────────────────────
-- vim-alda's stop only pauses the player's MIDI sequencer: scheduled notes
-- survive and resume on the next play. The only thing that drops them is
-- shutting the player down, which the REPL's "new-score" op does — but it
-- also wipes the REPL state, so we immediately re-send the definitions
-- (everything above the first instrument part).

local function definitions()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for i, l in ipairs(lines) do
        if l:match("^%a[%w%-]*:%s*$") then
            return table.concat(lines, "\n", 1, i - 1)
        end
    end
    return table.concat(lines, "\n")
end

local function hard_stop()
    if vim.fn["alda#repl#Connected"]() ~= 1 then
        return vim.fn["alda#playing#StopPlayback"]() -- no REPL: original behavior
    end
    -- each plugin call is a separate process: wait, or the reload may arrive
    -- at the server before the reset and get wiped
    vim.fn.jobwait({ vim.fn["alda#repl#NewScore"]() }, 5000)
    vim.fn["alda#repl#Play"](definitions())
end

-- Buffer-local commands take precedence over the plugin's global one.
vim.api.nvim_buf_create_user_command(buf, "AldaStopPlayback", hard_stop,
    { desc = "Alda: hard stop (reset REPL, reload definitions)" })

-- Deferred like the block above: with lazy-loading, the plugin's own
-- <localleader>S would otherwise be defined after ours and overwrite it.
vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then
        vim.keymap.set("n", keys.hard_stop, hard_stop,
            { buffer = buf, desc = "Alda: hard stop (reset REPL, reload definitions)" })
    end
end)

-- ── Reset and reload ──────────────────────────────────────────────────
-- Same reset as the hard stop, but explicit and REPL-only: use it to start
-- from a clean slate (e.g. after the part offsets have drifted apart).
-- Without a REPL connection the plugin raises "Use AldaConnect first".
vim.keymap.set("n", keys.reset, function()
    vim.fn.jobwait({ vim.fn["alda#repl#NewScore"]() }, 5000)
    vim.fn["alda#repl#Play"](definitions())
end, { buffer = buf, desc = "Alda: reset REPL and reload definitions" })

-- ── Parse buffer without the shell ────────────────────────────────────
-- The plugin pretty-prints parse results with `bash -c "echo -e '<JSON>' |
-- jq ."`, i.e. the whole JSON goes into a single argument. Linux caps one
-- argument at 128 KiB, so any real score fails with E903 "argument list too
-- long". Here both alda and jq get their input on stdin via vim.system.
local has_jq = vim.fn.executable("jq") == 1
local alda_cmd = vim.g.alda_command or "alda"

local function show(text, is_json)
    vim.schedule(function()
        vim.cmd("vnew")
        vim.bo.buftype, vim.bo.bufhidden = "nofile", "wipe"
        vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(text, "\n", { plain = true }))
        if is_json then vim.bo.filetype = "json" end
        vim.keymap.set("n", "q", "<cmd>bd<cr>", { buffer = true, desc = "Close parse results" })
    end)
end

local function parse_buffer(extra_args)
    local code = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    local cmd = vim.list_extend({ alda_cmd, "parse" }, extra_args)
    vim.notify("Parsing score...")
    vim.system(cmd, { stdin = code, text = true }, function(res)
        if res.code ~= 0 then
            return show(res.stdout .. res.stderr, false)
        end
        if not has_jq then
            return show(res.stdout, true)
        end
        vim.system({ "jq", "." }, { stdin = res.stdout, text = true }, function(jq)
            show(jq.code == 0 and jq.stdout or res.stdout, true)
        end)
    end)
end

local function parse_data() parse_buffer({}) end
local function parse_events() parse_buffer({ "-o", "events" }) end

vim.api.nvim_buf_create_user_command(buf, "AldaParseBuffer", parse_data,
    { desc = "Alda: parse buffer (score data)" })
vim.api.nvim_buf_create_user_command(buf, "AldaParseBufferEvents", parse_events,
    { desc = "Alda: parse buffer (events)" })

-- Deferred so the plugin's own mappings (lazy-loaded) don't overwrite ours.
vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(buf) then return end
    vim.keymap.set("n", keys.parse_data, parse_data,
        { buffer = buf, desc = "Alda: parse buffer (score data)" })
    vim.keymap.set("n", keys.parse_events, parse_events,
        { buffer = buf, desc = "Alda: parse buffer (events)" })
end)
