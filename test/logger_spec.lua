---@param logger Logger
local function doLog(logger)
    logger.trace("trace")
    logger.debug("debug")
    logger.info("info")
    logger.warn("warn")
    logger.fatal("fatal")
    logger.error("eor")
end

describe("Logger builder, setup and use.", function()
    it("Vim logger", function()
        require("ltex_extra.utils.log"):__debug_reset()
        require("ltex_extra.utils.log"):new({ logLevel = "info", usePlenary = false })
        local logger = require("ltex_extra.utils.log").log
        doLog(logger)
    end)

    it("Plenary logger", function()
        require("ltex_extra.utils.log"):__debug_reset()
        require("ltex_extra.utils.log"):new({ logLevel = "info", usePlenary = true })
        local logger = require("ltex_extra.utils.log").log
        doLog(logger)
    end)
end)
