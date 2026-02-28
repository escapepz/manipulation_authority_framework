local pz_utils = require("pz_utils_shared")
local KUtilities = pz_utils.konijima.Utilities

local SafeLogger = pz_utils.escape.SafeLogger

SafeLogger.init("maf_example_rules")

return {
    SafeLogger = SafeLogger,
    KUtilities = KUtilities,
}
