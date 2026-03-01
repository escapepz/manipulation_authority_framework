local is_destroy_stuff_action =
    require("manipulation_authority_framework/patches/is_destroy_stuff_action_patch")
local is_dismantle_action =
    require("manipulation_authority_framework/patches/is_dismantle_action_patch")
local is_moveables_action =
    require("manipulation_authority_framework/patches/is_moveables_action_patch")

local ZUL = require("zul")
local pz_utils = require("pz_utils_shared")

local KUtilities = pz_utils.konijima.Utilities
local logger = ZUL.new("manipulation_authority_framework")

return function()
    if KUtilities.IsServerOrSinglePlayer() then
        logger:info("Initializing Shared Patches Hook...")

        Events.OnGameBoot.Add(function()
            logger:info("Applying shared server-side patches (Server Environment)...")
            is_destroy_stuff_action.serverSidePatch()
            is_dismantle_action.serverSidePatch()
            is_moveables_action.serverSidePatch()
        end)

        if KUtilities.IsSinglePlayer() then
            Events.OnGameStart.Add(function()
                logger:info("Applying shared server-side patches (SP/Local)...")
                is_destroy_stuff_action.serverSidePatch()
                is_dismantle_action.serverSidePatch()
                is_moveables_action.serverSidePatch()
            end)
        end
    end
end
