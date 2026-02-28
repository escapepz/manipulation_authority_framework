local is_destroy_cursor_patch =
    require("manipulation_authority_framework/patches/is_destroy_cursor_patch")
local is_moveable_cursor_patch =
    require("manipulation_authority_framework/patches/is_moveable_cursor_patch")

local ZUL = require("zul")
local logger = ZUL.new("maf_server_patches")

return function()
    logger:info("Initializing Server Patches Hook...")
    ---@diagnostic disable-next-line: unnecessary-if
    if isServer() then
        Events.OnGameBoot.Add(function()
            logger:info("Applying server-side patches (Server Environment)...")
            -- is_destroy_cursor_patch()
            -- is_moveable_cursor_patch()
        end)
    end

    -- Cursors also need to load on client start to ensure they are active for the local player
    Events.OnGameStart.Add(function()
        if not isMultiplayer() then
            logger:info("Applying server-side patches (SP/Local)...")
        end
        logger:info("Applying cursor patches (Client UI)...")
        -- is_destroy_cursor_patch()
        -- is_moveable_cursor_patch()
    end)
end
