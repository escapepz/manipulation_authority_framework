local MAFV = require("manipulation_authority_framework_client")

local pz_utils = require("pz_utils_shared")
local SafeLogger = pz_utils.escape.SafeLogger
SafeLogger.init("maf_example_rules_client")

local tostring = tostring

---Visual rule example: Check if manipulated object has a certain condition to display on the cursor
local function visualDestroyCursorExample(context)
    -- This runs on the client every frame while the cursor is active
    -- Performance is critical here!

    -- Example: only run for ISDestroyCursor
    if context.actionType ~= "DestroyCursor" then
        return
    end

    local object = context.object

    -- For example, simulate that some objects cannot be destroyed
    if object and object:getModData() and object:getModData().indestructible then
        -- Rejecting a visual context turns the cursor red (or shows a specific tooltip)
        context.flags.rejected = true
        context.flags.reason = "Indestructible Object"

        -- Optionally log, but carefully because this fires every frame
        if SafeLogger.shouldLog and SafeLogger.shouldLog(5) then
            SafeLogger.log("[MAF:VisualExample] Cursor rejected for indestructible object", 5)
        end
    end
end

return function()
    if not MAFV then
        SafeLogger.log(
            "[MAF] Error: MAF Visual singleton missing during visual_cursor_example registration!",
            50
        )
        return
    end

    -- Register the visual hook
    MAFV:registerRule("visual_cursor_example", visualDestroyCursorExample, 200)

    SafeLogger.log("[MAF] Visual Cursor Example Rule loaded.", 30)
end
