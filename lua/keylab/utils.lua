local M = {}
local api = vim.api

M.center_text = function (text, width)
    return string.rep(' ', width/2 - string.len(text)/2) .. text
end

local ns = api.nvim_create_namespace("keylab")

M.green_hl = function (row, col_start, col_end)
    api.nvim_buf_add_highlight(0, ns, "Directory", row-1, col_start-1, col_end)
end

M.red_hl = function (row, col_start, col_end)
    api.nvim_buf_add_highlight(0, ns, "ErrorMsg", row-1, col_start-1, col_end)
end

M.clear_hl = function()
    api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

return M

