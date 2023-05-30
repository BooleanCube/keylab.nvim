
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
            lines = 15,
            force_accuracy = true,
            correct_fg = "#ffffff",
            wrong_bg = "#000000"
        })
        assert.equals(15, keylab.height)
        assert.equals(true, keylab.accurate_msr)
    end)
end)

