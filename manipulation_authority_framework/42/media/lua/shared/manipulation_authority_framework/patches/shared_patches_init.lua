local is_destroy_stuff_action =
    require("manipulation_authority_framework/patches/is_destroy_stuff_action_patch")
local is_dismantle_action =
    require("manipulation_authority_framework/patches/is_dismantle_action_patch")
local is_moveables_action =
    require("manipulation_authority_framework/patches/is_moveables_action_patch")

local ZUL = require("zul")
local logger = ZUL.new("maf_shared_patches")

return function()
    logger:info("Initializing Shared Patches Hook...")

    ---@diagnostic disable-next-line: unnecessary-if
    if isServer() then
        Events.OnGameBoot.Add(function()
            logger:info("Applying shared server-side patches (Server Environment)...")
            is_destroy_stuff_action.serverSidePatch()
            is_dismantle_action.serverSidePatch()
            is_moveables_action.serverSidePatch()
        end)
    end

    ---@diagnostic disable-next-line: unnecessary-if
    if not isMultiplayer() then
        Events.OnGameStart.Add(function()
            logger:info("Applying shared server-side patches (SP/Local)...")
            is_destroy_stuff_action.serverSidePatch()
            is_dismantle_action.serverSidePatch()
            is_moveables_action.serverSidePatch()
        end)
    end
end
