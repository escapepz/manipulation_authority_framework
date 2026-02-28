local MAF = require("manipulation_authority_framework")
local maf_utils = require("maf_example_rules")

local SafeLogger = maf_utils.SafeLogger

local tostring = tostring

---Validation rule example
local function validateMoveables(context)
    local ctx = context ---@type ManipulationAuthorityContext
    if context.actionType ~= "Moveables" then
        return
    end
    ---@diagnostic disable-next-line: unnecessary-if
    if SafeLogger.shouldLog and not SafeLogger.shouldLog(30) then
        return
    end

    local _object = ctx.object
    if _object then
        local modData = _object:getModData()
        if modData.immovable then
            context.flags.rejected = true
        end
    end

    SafeLogger.log("[MAF:MoveablesExample] Validate phase executed", 30)
end

---Pre-action rule example
local function preActionMoveables(context)
    local ctx = context ---@type ManipulationAuthorityContext
    if context.actionType ~= "Moveables" then
        return
    end
    ---@diagnostic disable-next-line: unnecessary-if
    if SafeLogger.shouldLog and not SafeLogger.shouldLog(30) then
        return
    end

    local _object = ctx.object
    if _object then
        local modData = _object:getModData()
        if modData.immovable then
            context.flags.rejected = true
        end
    end

    SafeLogger.log("[MAF:MoveablesExample] PreAction phase executed", 30)
end

---Post-action rule example
local function postActionMoveables(context)
    if context.actionType ~= "Moveables" then
        return
    end
    ---@diagnostic disable-next-line: unnecessary-if
    if SafeLogger.shouldLog and not SafeLogger.shouldLog(30) then
        return
    end
    SafeLogger.log("[MAF:MoveablesExample] PostAction phase executed", 30)
end

return function()
    if not MAF then
        return
    end
    MAF:registerRule("validate", "moveables_example_validate", validateMoveables, 200)
    MAF:registerRule("pre", "moveables_example_pre", preActionMoveables, 200)
    MAF:registerRule("post", "moveables_example_post", postActionMoveables, 200)
    SafeLogger.log("[MAF] Moveables Hooks Example loaded.", 30)
end
