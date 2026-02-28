local MAFV = require("manipulation_authority_framework_client")
local maf_utils = require("maf_example_rules")

local SafeLogger = maf_utils.SafeLogger

local tostring = tostring

---Visual rule example for sprite props (tooltips)
local function visualSpritePropsExample(context)
    if context.actionType ~= "MoveableSpriteProps" then
        return
    end

    local object = context.object

    -- For example, simulate that some objects cannot be interacted with
    if object and object:getModData() and object:getModData().immovable then
        context.flags.rejected = true
        context.flags.reason = "Immovable Structure"

        ---@diagnostic disable-next-line: unnecessary-if
        if SafeLogger.shouldLog and SafeLogger.shouldLog(5) then
            SafeLogger.log("[MAF:VisualExample] Sprite props tooltip rejected", 5)
        end
    end
end

return function()
    if not MAFV then
        return
    end
    MAFV:registerRule("visual_sprite_props_example", visualSpritePropsExample, 200)
    SafeLogger.log("[MAF] Visual Sprite Props Example Rule loaded.", 30)
end
