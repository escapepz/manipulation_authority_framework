local MAF = require("manipulation_authority_framework")
local maf_utils = require("maf_example_rules")

local SafeLogger = maf_utils.SafeLogger

local tostring = tostring

---Validation rule example: Check if manipulated object has a certain condition
local function validateDismantle(context)
    -- Only run for Dismantle action
    if context.actionType ~= "Dismantle" then
        return
    end

    if SafeLogger.shouldLog and not SafeLogger.shouldLog(20) then
        return
    end

    SafeLogger.log("[MAF:DismantleExample] Validate phase executed for Dismantle", 20)
end

---Pre-action rule example: Do something right before the manipulation happens
local function preActionDismantle(context)
    -- Only run for Dismantle action
    if context.actionType ~= "Dismantle" then
        return
    end

    if SafeLogger.shouldLog and not SafeLogger.shouldLog(20) then
        return
    end

    SafeLogger.log("[MAF:DismantleExample] PreAction phase executed for Dismantle", 20)
end

---Post-action rule example: Do something right after the manipulation successfully finishes
local function postActionDismantle(context)
    -- Only run for Dismantle action
    if context.actionType ~= "Dismantle" then
        return
    end

    if SafeLogger.shouldLog and not SafeLogger.shouldLog(20) then
        return
    end

    SafeLogger.log("[MAF:DismantleExample] PostAction phase executed for Dismantle", 20)
end

return function()
    if not MAF then
        SafeLogger.log(
            "[MAF] Error: MAF singleton missing during dismantle_example registration!",
            50
        )
        return
    end

    -- Register all three hooks specifically for dismantling
    MAF:registerRule("validate", "dismantle_example_validate", validateDismantle, 200)
    MAF:registerRule("pre", "dismantle_example_pre", preActionDismantle, 200)
    MAF:registerRule("post", "dismantle_example_post", postActionDismantle, 200)

    SafeLogger.log("[MAF] Dismantle Hooks Example Rules loaded.", 30)
end
