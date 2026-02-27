local info_window_patch = require("manipulation_authority_framework/patches/is_moveable_info_window_patch")
local icon_tooltip_patch = require("manipulation_authority_framework/patches/is_moveables_icon_tooltip_patch")

return function()
    Events.OnGameStart.Add(function()
        info_window_patch()
        icon_tooltip_patch()
        
        local logger = require("zul").new("maf_client_patches")
        logger:info("MAF Client-only UI patches initialized.")
    end)
end
