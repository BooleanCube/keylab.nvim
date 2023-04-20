P = function (v)
    print(vim.inspect(v))
    return v
end

RELOAD = function (...)
    return require("plenary.reload").reload_module(...)
end

R = function (name)
    RELOAD(name)
    require(require(name))
end
