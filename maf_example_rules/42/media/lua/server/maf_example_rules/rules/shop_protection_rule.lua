local MAF = require("manipulation_authority_framework")
local pz_utils = require("pz_utils_shared")
local SafeLogger = pz_utils.escape.SafeLogger
SafeLogger.init("maf_example_rules")

local tostring = tostring

---Validation rule to prevent players from manipulating "shops" they don't own.
local function validateShopProtection(context)
    local object = context.object
    local character = context.character

    -- Check if object belongs to a shop
    if object and object:getModData() and object:getModData().shopOwner then
        local owner = object:getModData().shopOwner
        if owner ~= character:getUsername() then
            context.flags.rejected = true
            context.flags.reason = "This object belongs to " .. tostring(owner) .. "'s shop."
        end
    end
end

return function()
    if not MAF then
        SafeLogger.log(
            "[MAF] Error: MAF singleton missing during shop_protection registration!",
            50
        )
        return
    end

    -- Register the rule
    MAF:registerRule("validate", "shop_protection", validateShopProtection, 100)

    SafeLogger.log("[MAF] Shop Protection Rule loaded.", 30)
end
