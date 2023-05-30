local M = {}
local api = vim.api
local lsp = vim.lsp
local utils = require("keylab.utils")
local perf = require("keylab.perf")

-- Default Configuration
local num_lines = 10
M.accurate_msr = true

M.setup = function (opts)
    local options = opts or {}

    M.height = options["lines"] or M.height
    num_lines = M.height
    if options["mode"] == "measure" then
        M.accurate_msr = false
    elseif options["mode"] == "practice" then
        M.accurate_msr = true
    end

    utils.custom_colors(opts)
end
local reset_state = function ()
    M.ended = false
    M.rbuf = nil
    M.wbuf = nil
    M.mbuf = nil
    M.rwin = nil
    M.wwin = nil
    M.mwin= nil
    M.script = {}
    M.goal = 0
    M.memory = {}
    M.width = 50
    M.height = num_lines
    M.start_time = nil
    M.duration = nil
    M.accuracy = 0
end

reset_state()

local menu_selection = function (letter)
    if M.ended then
        if letter == "<CR>" then
            api.nvim_win_close(M.mwin, true)
            M.start()
        end
        if letter == "q" then
            api.nvim_win_close(M.mwin, true)
        end
        return false
    end
    return true
end

local set_menu_mapping = function ()
    vim.keymap.set('n', "<CR>", function () menu_selection("<CR>") end, {buffer=M.mbuf})
    vim.keymap.set('n', "q", function () menu_selection("q") end, {buffer=M.mbuf})
end

local open_menu = function ()
    M.width = 80    -- width for menu window
    M.height = 10   -- height for menu window

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

    local ui = api.nvim_list_uis()[1]

    local win_opts = {
        relative = "editor",
        focusable = true,
        width = M.width,
        height = M.height,
        col = (ui.width/2) - (M.width/2),
        row = (ui.height/2) - (M.height/2),
        border = "rounded",
        anchor = "NW",
        style = "minimal",
        title = "keylab.nvim",
        title_pos = "center"
    }

    vim.schedule(function ()
        -- api.nvim_buf_detach(M.wbuf)
        api.nvim_win_close(M.rwin, true)
        api.nvim_win_close(M.wwin, true)
        api.nvim_buf_delete(M.rbuf, {force=true})
        api.nvim_buf_delete(M.wbuf, {force=true})

        M.mbuf = api.nvim_create_buf(false, true)
        api.nvim_buf_set_lines(M.mbuf, 0, num_lines, false, menu_text)
        api.nvim_buf_set_option(M.mbuf, "readonly", true)

        M.mwin = api.nvim_open_win(M.mbuf, true, win_opts)
        set_menu_mapping()
    end)
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

    if #script > num_lines then
        local start_line = math.random(1, #script-num_lines)
        local cut_script = {}
        for i=start_line, start_line+num_lines-1, 1 do
            if #script[i] > 0 then
                table.insert(cut_script, script[i])
            end
        end
        script = cut_script
    end
    M.script = script

    local max_width = M.width
    for i, line in ipairs(script) do
        max_width = math.min(M.width+10, math.max(max_width, #line+3))
        M.goal = M.goal + #line
        table.insert(M.memory, "")
    end
    M.width = max_width

    return true
end

local highlight_buf = function ()
    M.memory = api.nvim_buf_get_lines(M.wbuf, 0, -1, false)

    local text_score = 0
    local correct = 0
    utils.clear_hl(M.wbuf)

    local cursor = api.nvim_win_get_cursor(M.wwin)
    local x = cursor[1]
    local y = cursor[2]+3
    if x <= #M.script and y <= #M.script[x] then
        api.nvim_win_set_cursor(M.rwin, cursor)
    end

    for row=1,#M.memory do
        if row > #M.script then
            utils.red_hl(M.wbuf, row, 1, #M.memory[row])
        else
            local status = ""
            local last_idx = 1
            for col=1,#M.memory[row] do
                local new_status = ""
                if col > #M.script[row] then
                    new_status = "wrong"
                else
                    if M.memory[row]:sub(col, col) == M.script[row]:sub(col,col) then
                        new_status = "right"
                    else
                        new_status = "wrong"
                    end
                end
                if new_status ~= status then
                    if status == "right" then
                        text_score = text_score + (col-last_idx)
                        correct = correct + (col-last_idx)
                        utils.green_hl(M.wbuf, row, last_idx, col-1)
                    elseif status == "wrong" then
                        if M.accurate_msr == false then
                            text_score = text_score + (col-last_idx)
                        end
                        utils.red_hl(M.wbuf, row, last_idx, col-1)
                    end
                    last_idx = col
                    status = new_status
                end
            end
            if status == "right" then
                text_score = text_score + (#M.memory[row]-last_idx+1)
                correct = correct + (#M.memory[row]-last_idx+1)
                utils.green_hl(M.wbuf, row, last_idx, #M.memory[row])
            elseif status == "wrong" then
                if M.accurate_msr == false then
                    text_score = text_score + (#M.memory[row]-last_idx+1)
                end
                utils.red_hl(M.wbuf, row, last_idx, #M.memory[row])
            end
        end
    end

    M.accuracy = utils.round(correct / M.goal, 2)

    if M.goal == text_score then
        M.ended = true
        M.duration = os.time()-M.start_time
        open_menu()
    end
end

M.start = function ()
    local clients = lsp.get_active_clients(
        { bufnr=api.nvim_get_current_buf() }
    )

    reset_state()
    local successful = generate_script()
    if not successful then
        return false
    end

    local ui = api.nvim_list_uis()[1]

    local rwin_opts = {
        relative = "editor",
        focusable = true,
        width = M.width,
        height = M.height,
        col = (ui.width/2) - M.width,
        row = (ui.height/2) - (M.height/2),
        anchor = "NW",
        style = "minimal",
        border = "single",
        title = "original script:",
        title_pos = "center"
    }

    local wwin_opts = {
        relative = "editor",
        focusable = true,
        width = M.width,
        height = M.height,
        col = (ui.width/2) + 1,
        row = (ui.height/2) - (M.height/2),
        anchor = "NW",
        style = "minimal",
        border = "single",
        title = "typing ground:",
        title_pos = "center"
    }

    M.rbuf = api.nvim_create_buf(false, true)
    M.wbuf = api.nvim_create_buf(false, true)

    for i=1, #clients do
        local client = clients[i]
        lsp.buf_attach_client(M.wbuf, client["id"])
        lsp.buf_attach_client(M.rbuf, client["id"])
    end

    api.nvim_buf_set_lines(M.rbuf, 0, num_lines, false, M.script)
    api.nvim_buf_set_option(M.rbuf, "readonly", true)

    M.rwin = api.nvim_open_win(M.rbuf, true, rwin_opts)
    M.wwin = api.nvim_open_win(M.wbuf, true, wwin_opts)

    api.nvim_buf_attach(M.wbuf, false, {
        on_lines = function() highlight_buf() end
    })
    M.start_time = os.time()

    return successful
end

return M

