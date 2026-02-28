local MAF = require("manipulation_authority_framework")
local maf_utils = require("maf_example_rules")

local SafeLogger = maf_utils.SafeLogger

local tostring = tostring

---Validation rule example: Check if manipulated object has a certain condition
local function validateDestroyCursor(context)
    -- Only run for DestroyCursor action
    if context.actionType ~= "DestroyCursor" then
        return
    end

    if SafeLogger.shouldLog and not SafeLogger.shouldLog(20) then
        return
    end

    SafeLogger.log("[MAF:DestroyCursorExample] Validate phase executed for DestroyCursor", 20)
end

---Pre-action rule example: Do something right before the manipulation happens
local function preActionDestroyCursor(context)
    -- Only run for DestroyCursor action
    if context.actionType ~= "DestroyCursor" then
        return
    end

    if SafeLogger.shouldLog and not SafeLogger.shouldLog(20) then
        return
    end

    SafeLogger.log("[MAF:DestroyCursorExample] PreAction phase executed for DestroyCursor", 20)
end

---Post-action rule example: Do something right after the manipulation successfully finishes
local function postActionDestroyCursor(context)
    -- Only run for DestroyCursor action
    if context.actionType ~= "DestroyCursor" then
        return
    end

    if SafeLogger.shouldLog and not SafeLogger.shouldLog(20) then
        return
    end

    SafeLogger.log("[MAF:DestroyCursorExample] PostAction phase executed for DestroyCursor", 20)
end

return function()
    if not MAF then
        SafeLogger.log(
            "[MAF] Error: MAF singleton missing during destroy_cursor_example registration!",
            50
        )
        return
    end

    -- Register all three hooks specifically for destroying with cursor
    MAF:registerRule("validate", "destroy_cursor_example_validate", validateDestroyCursor, 200)
    MAF:registerRule("pre", "destroy_cursor_example_pre", preActionDestroyCursor, 200)
    MAF:registerRule("post", "destroy_cursor_example_post", postActionDestroyCursor, 200)

    SafeLogger.log("[MAF] Destroy Cursor Hooks Example Rules loaded.", 30)
end
