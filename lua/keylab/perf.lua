local Path = require("plenary.path")

local fn = vim.fn
local data_path = fn.stdpath("data")
local storage_path = string.format("%s/keylab.json", data_path)

local M = {
    -- {record, average, count}
    performance = {}
}

local load_json = function (path)
    return fn.json_decode(Path:new(path):read())
end

local update_json = function ()
    Path:new(storage_path):write(fn.json_encode(M.performance), 'w')
end

M.load_perf = function ()
    local ok, res = pcall(load_json, storage_path)
    if ok then
        M.performance = res
    else
        M.performance = {0, 0, 0, 0}
    end
end

M.repr = function (time)
    local pr = M.performance[1]
    local avg = M.performance[2]
    local cnt = M.performance[3]

    pr = math.min(pr, time)
    cnt = cnt + 1
    avg = (avg*cnt+time)/cnt

    M.performance = {pr, avg, cnt}
    update_json()

    return "Best: " .. pr .. ", Avg: " .. avg
end

return M
