---@param logger Logger
local function doLog(logger)
    logger.trace("trace")
    logger.debug("debug")
    logger.info("info")
    logger.warn("warn")
    logger.error("error")
    logger.fatal("fatal")
    return true
end

describe("Logger: Builders and use", function()
    before_each(function()
        require("ltex_extra").__debug_reset()
        require("ltex_extra.utils.log"):__debug_reset()
    end)

    it("Plenary logger builder", function()
        require("ltex_extra.utils.log"):new({ logLevel = "warn", usePlenary = true })
        local logger = require("ltex_extra.utils.log").log
        assert(doLog(logger) == true, "doLog function didn't finish its execution")
    end)

    it("Vim logger builder", function()
        require("ltex_extra.utils.log"):new({ logLevel = "warn", usePlenary = false })
        local logger = require("ltex_extra.utils.log").log
        assert(doLog(logger) == true, "doLog function didn't finish its execution")
    end)

    it("Get logger from ltex extra", function()
        local opts = require("ltex_extra.opts").tests_opts
        require("ltex_extra").setup(opts)
        local logger = require("ltex_extra.utils.log").log
        assert(doLog(logger) == true, "doLog function didn't finish its execution")
    end)
end)
