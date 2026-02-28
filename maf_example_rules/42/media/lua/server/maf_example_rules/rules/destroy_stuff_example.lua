local MAF = require("manipulation_authority_framework")
local pz_utils = require("pz_utils_shared")
local SafeLogger = pz_utils.escape.SafeLogger
SafeLogger.init("maf_example_rules")

local tostring = tostring

---Validation rule example
local function validateDestroyStuff(context)
    if context.actionType ~= "DestroyStuff" then
        return
    end
    if SafeLogger.shouldLog and not SafeLogger.shouldLog(20) then
        return
    end
    SafeLogger.log("[MAF:DestroyStuffExample] Validate phase executed", 20)
end

---Pre-action rule example
local function preActionDestroyStuff(context)
    if context.actionType ~= "DestroyStuff" then
        return
    end
    if SafeLogger.shouldLog and not SafeLogger.shouldLog(20) then
        return
    end
    SafeLogger.log("[MAF:DestroyStuffExample] PreAction phase executed", 20)
end

---Post-action rule example
local function postActionDestroyStuff(context)
    if context.actionType ~= "DestroyStuff" then
        return
    end
    if SafeLogger.shouldLog and not SafeLogger.shouldLog(20) then
        return
    end
    SafeLogger.log("[MAF:DestroyStuffExample] PostAction phase executed", 20)
end

return function()
    if not MAF then
        return
    end
    MAF:registerRule("validate", "destroy_stuff_example_validate", validateDestroyStuff, 200)
    MAF:registerRule("pre", "destroy_stuff_example_pre", preActionDestroyStuff, 200)
    MAF:registerRule("post", "destroy_stuff_example_post", postActionDestroyStuff, 200)
    SafeLogger.log("[MAF] Destroy Stuff Hooks Example loaded.", 30)
end
