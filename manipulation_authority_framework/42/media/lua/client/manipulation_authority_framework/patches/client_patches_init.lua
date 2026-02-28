local info_window_patch =
    require("manipulation_authority_framework/patches/is_moveable_info_window_patch")
local icon_tooltip_patch =
    require("manipulation_authority_framework/patches/is_moveables_icon_tooltip_patch")

local ZUL = require("zul")
local logger = ZUL.new("maf_client_patches")

return function()
    logger:info("Initializing Client Patches Hook...")
    Events.OnGameStart.Add(function()
        logger:info("Applying client-only UI patches...")
        -- info_window_patch()
        -- icon_tooltip_patch()
    end)
end
