local pz_utils = require("pz_utils_shared")
local KUtilities = pz_utils.konijima.Utilities
local ZUL = require("zul")

-- Initialize a dedicated ZUL instance for the example mod
-- This prevents topic collision with other mods using the same logging library
local logger = ZUL.new("maf_example_rules")

-- Create a SafeLogger-compatible wrapper to maintain existing API in rules
local SafeLogger = {
    log = function(msg, level)
        -- Level 30+ is typically info/audit, 50+ is error
        if level <= 20 then
            logger:debug(msg)
        elseif level <= 40 then
            logger:info(msg)
        else
            logger:error(msg)
        end
    end,
    shouldLog = function(_)
        return true -- Simplify for example mod, or implement level check
    end,
}

return {
    SafeLogger = SafeLogger,
    KUtilities = KUtilities,
    logger = logger, -- Also expose raw ZUL logger
}
