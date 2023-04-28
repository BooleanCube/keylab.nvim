
describe("keylab configuration testing", function()
    before_each(function ()
        package.loaded["keylab"] = nil
    end)

    it("can be required", function()
        require("keylab")
    end)

    it("can be configured", function ()
        local keylab = require("keylab")
        keylab.setup({
            LINES = 15,
            correct_fg = "#ffffff",
            wrong_bg = "#000000"
        })
        assert.equals(15, keylab.height)
    end)
end)

