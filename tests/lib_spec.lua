
describe("statistics calculation testing", function()
    before_each(function ()
        package.loaded["keylab.perf"] = nil
        package.loaded["keylab.utils"] = nil

    end)

    it("can be required", function()
        require("keylab.perf")
        require("keylab.utils")
    end)

    it("can calculate correctly", function ()
        local perf = require("keylab.perf")
        local utils = require("keylab.utils")
        assert.equals(286.7, utils.round(perf.calculate_cpm(45, 215), 1))
    end)
end)

