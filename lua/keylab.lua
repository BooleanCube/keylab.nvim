local M = {}
local api = vim.api
local utils = require("keylab.utils")

local LINES = 15

M.setup = function (opts)
    local options = opts or {}
    P(options)
end

local reset_state = function ()
    M.ended = false
    M.buf = nil
    M.win = nil
    M.script = {}
    M.start_col = {}
    M.memory = {}
    M.width = 80
    M.height = LINES
    M.start_time = nil
    M.end_time = nil
end

reset_state()

local generate_script = function ()
    local script_buf = api.nvim_get_current_buf()
    local script = api.nvim_buf_get_lines(
        script_buf,
        1,
        api.nvim_buf_line_count(script_buf),
        true
    )

    if #script > LINES then
        local start_line = math.random(1, #script-LINES)
        local cut_script = {}
        for i=start_line, start_line+LINES-1, 1 do
            if #script[i] > 0 then
                table.insert(cut_script, script[i])
                local spaces = 0
                for chr in script[i]:gmatch(".") do
                    if chr == " " then
                        spaces = spaces+1
                    else
                        break
                    end
                end
                table.insert(M.start_col, spaces)
            end
        end
        script = cut_script
    end
    M.script = script

    local max_width = M.width
    for _, line in ipairs(script) do
        max_width = math.min(M.width+20, math.max(max_width, #line+3))
        table.insert(M.memory, "")
    end
    M.width = max_width
end

local reset_buf_lines = function ()
    local new_script = {}
    for i=1, #M.memory do
        local line = M.script[i]
        if #M.memory[i] > #M.script[i]-M.start_col[i] then
            line = line .. M.memory[i]:sub(#M.script[i]-M.start_col[i]+1, #M.memory[i])
        else
        end
        table.insert(new_script, line)
    end
    api.nvim_buf_set_lines(M.buf, 0, LINES, false, new_script)
end

local highlight_buf = function ()
    utils.clear_hl()

    local buf_lines = {}
    for i=1,#M.memory do
        local spaces = ""
        for j=1,M.start_col[i] do
            spaces = spaces .. " "
        end
        table.insert(buf_lines, spaces .. M.memory[i])
    end
    for row=1,#buf_lines do
        if row > #M.script then
            -- rare scenario
            local start = 1
            for col=1,#buf_lines[row] do
                if buf_lines[row][col] == " " then
                    start = start + 1
                else
                    break
                end
            end
            utils.red_hl(row, start, #buf_lines[row])
        else
            local pass = false
            local status = ""
            local last_idx = 1
            print(M.script[row] .. " " .. buf_lines[row])
            for col=1,#buf_lines[row] do
                if not pass then
                    if buf_lines[row][col] ~= " " then
                        pass = true
                    end
                    last_idx = col
                end
                if pass then
                    local new_status = ""
                    if col > #M.script[row] then
                        new_status = "wrong"
                        return
                    else
                        if buf_lines[row][col] == M.script[row][col] then
                            new_status = "right"
                        else
                            new_status = "wrong"
                        end
                    end
                    if new_status ~= status then
                        print(last_idx .. " " .. status)
                        if status == "right" then
                            utils.green_hl(row, last_idx, col-1)
                        elseif status == "wrong" then
                            utils.red_hl(row, last_idx, col-1)
                        end
                        last_idx = col
                        status = new_status
                    end
                end
            end
            if status == "right" then
                utils.green_hl(row, last_idx, #buf_lines[row])
            elseif status == "wrong" then
                utils.red_hl(row, last_idx, #buf_lines[row])
            end
        end
    end
end

local key_pressed = function (letter)
    if M.ended then
        return false
    end

    local cursor = api.nvim_win_get_cursor(0)
    local row = cursor[1]
    local col = cursor[2]+1
    local row_off = 0
    local col_off = 0

    if not M.ended and col < M.start_col[row] then
        return false
    end
    if letter == "<BS>" and col > 2 then
        local offset = M.start_col[row]
        if col-1 <= #M.memory[row]+offset then
            M.memory[row] =
                    M.memory[row]:sub(1, col-offset-2) ..
                    M.memory[row]:sub(col-offset, #M.memory[row]);
        end
        col_off = -2
    elseif letter == "<CR>" then
        if M.ended then
            -- do stuff
            return false
        elseif row <= #M.script then
            row_off = 1
            col_off = M.start_col[row+1] - col
        end
    else
        local offset = M.start_col[row]
        M.memory[row] =
                M.memory[row]:sub(1, col-offset-1) ..
                letter ..
                M.memory[row]:sub(col-offset, #M.memory[row]);
    end

    -- api.nvim_buf_set_lines(M.buf, 0, LINES, false, M.memory)
    reset_buf_lines()
    highlight_buf()
    api.nvim_win_set_cursor(0, {row+row_off, col+col_off})
end

local set_mapping = function ()
    for i=32,126,1 do
        local chr = string.char(i)
        vim.keymap.set('i', chr, function() key_pressed(chr) end, {buffer=0})
    end
    vim.keymap.set('i', "<BS>", function () key_pressed("<BS>") end, {buffer=0})
    vim.keymap.set('i', "<CR>", function () key_pressed("<CR>") end, {buffer=0})
    -- vim.keymap.set('i', "<Tab>", function () key_pressed("<Tab>") end, {buffer=0})
end

M.start = function ()
    reset_state()
    generate_script()

    local ui = api.nvim_list_uis()[1]
    M.buf = api.nvim_create_buf(false, true)
    -- api.nvim_buf_set_option(M.buf, "readonly", true)
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
    M.win = api.nvim_open_win(M.buf, true, win_opts)
    -- api.nvim_command("botright vnew")

    set_mapping()
    M.start_time = os.time()
end

return M

