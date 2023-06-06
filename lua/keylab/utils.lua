local M = {}
local api = vim.api

local colors = {
    Directory = { fg="#B80026" },
    ErrorMsg = { bg="#FB4934" }
}

M.round = function (num, dp)
    local mult = 10^(dp or 0)
    return math.floor(num * mult + 0.5)/mult
end

M.index_of = function (t, e)
    local index = {}
    for k,v in pairs(t) do
        index[v] = k
    end
    return index[e]
end

M.center_text = function (text, width)
    return string.rep(' ', width/2 - string.len(text)/2) .. text
end

local ns = api.nvim_create_namespace("keylab")

local set_colors = function ()
    for name, setting in pairs(colors) do
        api.nvim_set_hl(ns, name, setting)
    end
end

set_colors()

M.custom_colors = function (opts)
    if opts["correct_fg"] ~= nil then
        colors["Directory"] = { fg=opts["correct_fg"] }
    end
    if opts["wrong_bg"] ~= nil then
        colors["ErrorMsg"] = { bg=opts["wrong_bg"] }
    end
    set_colors()
end

M.green_hl = function (buf, row, col_start, col_end)
    api.nvim_buf_add_highlight(buf, ns, "Directory", row-1, col_start-1, col_end)
end

M.red_hl = function (buf, row, col_start, col_end)
    api.nvim_buf_add_highlight(buf, ns, "ErrorMsg", row-1, col_start-1, col_end)
end

M.clear_hl = function(buf)
    api.nvim_buf_clear_namespace(buf, ns, 0, -1)
end

return M

