local is_destroy_cursor_patch = require("manipulation_authority_framework/patches/is_destroy_cursor_patch")
local is_moveable_cursor_patch = require("manipulation_authority_framework/patches/is_moveable_cursor_patch")

return function()
    Events.OnGameBoot.Add(function()
        is_destroy_cursor_patch()
        is_moveable_cursor_patch()
    end)
end
