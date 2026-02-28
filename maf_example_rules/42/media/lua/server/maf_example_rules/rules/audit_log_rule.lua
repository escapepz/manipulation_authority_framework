local MAF = require("manipulation_authority_framework")
local maf_utils = require("maf_example_rules")

local SafeLogger = maf_utils.SafeLogger

local tostring = tostring

---Post-action rule to log successful manipulations for auditing.
local function logManipulation(context)
    if SafeLogger.shouldLog and not SafeLogger.shouldLog(20) then
        return
    end

    local char = context.character
    local actionType = context.actionType
    local objName = context.object and context.object:getObjectName() or "unknown"
    local square = context.square
    local locationStr = "unknown"
    if square then
        locationStr = tostring(square:getX())
            .. ","
            .. tostring(square:getY())
            .. ","
            .. tostring(square:getZ())
    end

    SafeLogger.log(
        "[MAF:Audit] Player "
            .. tostring(char:getUsername())
            .. " performed "
            .. tostring(actionType)
            .. " on "
            .. tostring(objName)
            .. " at "
            .. locationStr,
        20
    )
end

return function()
    if not MAF then
        SafeLogger.log("[MAF] Error: MAF singleton missing during audit_log registration!", 50)
        return
    end

    -- Register the rule
    MAF:registerRule("post", "audit_log", logManipulation, 500)

    SafeLogger.log("[MAF] Audit Log Rule loaded.", 30)
end
