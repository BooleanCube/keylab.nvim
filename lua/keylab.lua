local M = {}
local api = vim.api
local utils = require("keylab.utils")
local perf = require("keylab.perf")

-- Default Configuration
local LINES = 10
M.accurate_msr = true

M.setup = function (opts)
    local options = opts or {}

    M.height = options["LINES"] or M.height
    LINES = M.height
    if options["force_accuracy"] ~= nil then
        M.accurate_msr = options["force_accuracy"]
    end

    utils.custom_colors(opts)
end

local reset_state = function ()
    M.ended = false
    M.buf = nil
    M.win = nil
    M.script = {}
    M.goal = 0
    M.start_col = {}
    M.memory = {}
    M.width = 80
    M.height = LINES
    M.start_time = nil
    M.duration = nil
    M.accuracy = 0
end

reset_state()

local open_menu = function ()
    perf.load_perf()
    local cpm = perf.calculate_cpm(M.duration, M.goal, M.accuracy)
    local menu_text = {
        "",
        "",
        utils.center_text(string.format("Speed: %d CPM, Accuracy: %d%%", cpm, M.accuracy*100), M.width),
        "",
        utils.center_text(perf.repr(cpm), M.width),
        "",
        utils.center_text("Press <CR> to restart the game with the same script", M.width),
        utils.center_text("Press q to close keylab", M.width),
        "",
        ""
    }
    api.nvim_buf_set_lines(M.buf, 0, LINES, false, menu_text)
end

local generate_script = function ()
    if #M.script > 0 then
        return true
    end

    local script_buf = api.nvim_get_current_buf()
    local script = api.nvim_buf_get_lines(
        script_buf,
        1,
        api.nvim_buf_line_count(script_buf),
        true
    )

    if #script == 0 then
        return false
    end

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
    for i, line in ipairs(script) do
        max_width = math.min(M.width+20, math.max(max_width, #line+3))
        M.goal = M.goal + (#line-M.start_col[i])
        table.insert(M.memory, "")
    end
    M.width = max_width

    return true
end

local reset_buf_lines = function ()
    local new_script = {}
    for i=1, #M.memory do
        local line = M.script[i]
        if #M.memory[i] > #M.script[i]-M.start_col[i] then
            line = line .. M.memory[i]:sub(#M.script[i]-M.start_col[i]+1, #M.memory[i])
        end
        table.insert(new_script, line)
    end
    api.nvim_buf_set_lines(M.buf, 0, LINES, false, new_script)
end

local highlight_buf = function ()
    local text_score = 0
    local correct = 0
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
            for col=1,#buf_lines[row] do
                if not pass then
                    if buf_lines[row]:sub(col,col) ~= " " then
                        pass = true
                    end
                    last_idx = col
                end
                if pass then
                    local new_status = ""
                    if col > #M.script[row] then
                        new_status = "wrong"
                    else
                        if buf_lines[row]:sub(col, col) == M.script[row]:sub(col,col) then
                            new_status = "right"
                        else
                            new_status = "wrong"
                        end
                    end
                    if new_status ~= status then
                        if status == "right" then
                            text_score = text_score + (col-last_idx)
                            correct = correct + (col-last_idx)
                            utils.green_hl(row, last_idx, col-1)
                        elseif status == "wrong" then
                            if M.accurate_msr == false then
                                text_score = text_score + (col-last_idx)
                            end
                            utils.red_hl(row, last_idx, col-1)
                        end
                        last_idx = col
                        status = new_status
                    end
                end
            end
            if status == "right" then
                text_score = text_score + (#buf_lines[row]-last_idx+1)
                correct = correct + (#buf_lines[row]-last_idx+1)
                utils.green_hl(row, last_idx, #buf_lines[row])
            elseif status == "wrong" then
                if M.accurate_msr == false then
                    text_score = text_score + (#buf_lines[row]-last_idx+1)
                end
                utils.red_hl(row, last_idx, #buf_lines[row])
            end
        end
    end

    if M.goal == text_score then
        M.ended = true
        M.duration = os.time()-M.start_time
        open_menu()
    end

    M.accuracy = utils.round(correct / M.goal, 2)
end

local key_pressed = function (letter)
    if M.ended then
        if letter == "<CR>" then
            M.ended = false
            for i=1, #M.memory do
                M.memory[i] = ""
            end
            M.duration = nil

            api.nvim_buf_set_lines(M.buf, 0, LINES, false, M.script)

            M.start_time = os.time()
        end
        if letter == "q" then
            api.nvim_win_close(0, true)
        end
        return false
    end

    local cursor = api.nvim_win_get_cursor(0)
    local row = cursor[1]
    local col = cursor[2]
    local row_off = 0
    local col_off = 0
    local offset = M.start_col[row]

    if letter == "<BS>" then
        if col <= #M.memory[row]+offset and col > offset then
            local idx = col-offset
            if idx == 1 then
                M.memory[row] = ""
            elseif idx == #M.memory[row] then
                M.memory[row] = M.memory[row]:sub(1, #M.memory[row]-1)
            else
                M.memory[row] =
                        M.memory[row]:sub(1, idx-1) ..
                        M.memory[row]:sub(idx+1, #M.memory[row]);
            end
            col_off = -1
        end
    elseif letter == "<CR>" then
        if row < #M.script then
            row_off = 1
            col_off = M.start_col[row+1] - col
        end
    elseif col >= offset then
        local idx = col-offset
        if idx == 0 then
            M.memory[row] = letter
        elseif idx == #M.memory[row] then
            M.memory[row] = M.memory[row] .. letter
        else
            M.memory[row] =
                    M.memory[row]:sub(1, col-offset) ..
                    letter ..
                    M.memory[row]:sub(col-offset+1, #M.memory[row]);
        end
        col_off = 1
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
    vim.keymap.set('n', "<CR>", function () key_pressed("<CR>") end, {buffer=0})
    vim.keymap.set('i', "q", function () key_pressed("q") end, {buffer=0})
    vim.keymap.set('n', "q", function () key_pressed("q") end, {buffer=0})
    -- vim.keymap.set('i', "<Tab>", function () key_pressed("<Tab>") end, {buffer=0})
end

M.start = function ()
    reset_state()
    local successful = generate_script()

    if not successful then
        return false
    end

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

    return successful
end

return M

