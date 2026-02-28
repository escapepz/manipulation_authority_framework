local MAF = require("manipulation_authority_framework")
local maf_utils = require("maf_example_rules")

local SafeLogger = maf_utils.SafeLogger

local tostring = tostring

---Validation rule example
local function validateDestroyStuff(context)
    local ctx = context ---@type ManipulationAuthorityContext
    if ctx.actionType ~= "DestroyStuff" then
        return
    end

    ---@diagnostic disable-next-line: unnecessary-if
    if SafeLogger.shouldLog and not SafeLogger.shouldLog(30) then
        return
    end

    local _object = ctx.object
    if _object then
        local modData = _object:getModData()
        if modData.indestructible then
            ctx.flags.rejected = true
        end
    end

    SafeLogger.log("[MAF:DestroyStuffExample] Validate phase executed", 30)
end

---Pre-action rule example
local function preActionDestroyStuff(context)
    local ctx = context ---@type ManipulationAuthorityContext
    if ctx.actionType ~= "DestroyStuff" then
        return
    end

    ---@diagnostic disable-next-line: unnecessary-if
    if SafeLogger.shouldLog and not SafeLogger.shouldLog(30) then
        return
    end

    local _object = ctx.object
    if _object then
        local modData = _object:getModData()
        if modData.indestructible then
            ctx.flags.rejected = true
        end
    end

    SafeLogger.log("[MAF:DestroyStuffExample] PreAction phase executed", 30)
end

---Post-action rule example
local function postActionDestroyStuff(context)
    if context.actionType ~= "DestroyStuff" then
        return
    end
    ---@diagnostic disable-next-line: unnecessary-if
    if SafeLogger.shouldLog and not SafeLogger.shouldLog(30) then
        return
    end
    SafeLogger.log("[MAF:DestroyStuffExample] PostAction phase executed", 30)
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
