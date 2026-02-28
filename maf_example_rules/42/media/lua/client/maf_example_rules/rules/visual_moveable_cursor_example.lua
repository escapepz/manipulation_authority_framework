local MAFV = require("manipulation_authority_framework_client")

local pz_utils = require("pz_utils_shared")
local SafeLogger = pz_utils.escape.SafeLogger
SafeLogger.init("maf_example_rules_client")

local tostring = tostring

---Visual rule example for Moveable Cursor
local function visualMoveableCursorExample(context)
    if context.actionType ~= "MoveableCursor" then
        return
    end

    local object = context.object

    -- For example, simulate that some objects cannot be moved
    if object and object:getModData() and object:getModData().immovable then
        context.flags.rejected = true
        context.flags.reason = "Fixed Position"

        if SafeLogger.shouldLog and SafeLogger.shouldLog(5) then
            SafeLogger.log("[MAF:VisualExample] Cursor rejected for immovable object", 5)
        end
    end
end

return function()
    if not MAFV then
        return
    end
    MAFV:registerRule("visual_moveable_cursor_example", visualMoveableCursorExample, 200)
    SafeLogger.log("[MAF] Visual Moveable Cursor Example Rule loaded.", 30)
end
