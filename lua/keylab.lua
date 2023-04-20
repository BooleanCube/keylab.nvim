local M = {}

local api = vim.api

local LINES = 10

M.setup = function (opts)
    local options = opts or {}
    P(options)
end

local reset_state = function ()
    M.session_ended = false
    M.buf = nil
    M.memory = ""
    M.found = 0
    M.script = {}
    M.highlight_starts = {}
    M.width = 50
    M.height = LINES
    M.start_time = nil
    M.end_time = nil
end

reset_state()

local generate_script = function ()
    local script_buf = api.nvim_get_current_buf()
    local script = api.nvim_buf_get_lines(script_buf, 1, api.nvim_buf_line_count(script_buf), true)

    if #script > LINES then
        local start_line = math.random(1, #script-LINES)
        local cut_script = {}
        for i=start_line, start_line+LINES-1, 1 do
            if #script[i] > 0 then
                table.insert(cut_script, script[i])
            end
        end
        script = cut_script
    end
    M.script = script

    local max_width = 50
    for _, line in ipairs(script) do
        max_width = math.max(max_width, #line+3)
    end
    M.width = max_width
end

local key_pressed = function (letter)
    if letter == "<Tab>" then
        return false
    end

    if letter == "<BS>" then
        return false
    end

    if letter == "<CR>" then
        return false
    end

    return true
end

local set_mapping = function ()
    for i=32,126,1 do
        local chr = string.char(i)
        vim.keymap.set('i', chr, function() key_pressed(chr) end)
    end
    vim.keymap.set('i', "<BS>", function () key_pressed("<BS>") end)
    vim.keymap.set('i', "<CR>", function () key_pressed("<CR>") end)
    vim.keymap.set('i', "<Tab>", function () key_pressed("<Tab>") end)
end

M.start = function ()
    reset_state()
    generate_script()

    local ui = api.nvim_list_uis()[1]

    M.buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(M.buf, 0, LINES, false, M.script)

    local win_opts = {
        relative = "editor",
        width = M.width,
        height = M.height,
        col = (ui.width/2) - (M.width/2),
        row = (ui.height/2) - (M.height/2),
        border = "rounded",
        anchor = "NW",
        style = "minimal",
        title = "Keylab",
        title_pos = "center"
    }

    api.nvim_open_win(M.buf, true, win_opts)

    M.start_time = os.time()
end

return M

