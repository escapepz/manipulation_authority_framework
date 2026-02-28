-- It's in the server/ directory, but only runs on the client.
-- Never put an isServer() guard at the top of any file inside the server/ folder.
local serverSidePatch = function()
    -- MAF is for server toggle
    -- MAFV is for visual client side rules

    local MAF = _G.ManipulationAuthorityFramework
    local MAFV = _G.ManipulationAuthorityFrameworkVisual

    local original_canDestroy = ISDestroyCursor.canDestroy
    function ISDestroyCursor:canDestroy(object)
        ---@diagnostic disable-next-line: unnecessary-if
        if MAF and MAF.config.ISDestroyCursorProtection and MAFV and object then
            local ctx =
                MAFV:getVisualContext("DestroyCursor", object, self.character, object:getSquare())
            MAFV:processAction(ctx)
            if ctx.flags.rejected then
                return false
            end
        end
        return original_canDestroy(self, object)
    end

    local original_isValid = ISDestroyCursor.isValid
    function ISDestroyCursor:isValid(square)
        ---@diagnostic disable-next-line: unnecessary-if
        if MAF and MAF.config.ISDestroyCursorProtection and MAFV and square then
            local objects = square:getObjects()
            for i = 0, objects:size() - 1 do
                local object = objects:get(i)

                -- Use pooled context for high-frequency visual check
                local ctx = MAFV:getVisualContext("DestroyCursor", object, self.character, square)
                MAFV:processAction(ctx)

                if ctx.flags.rejected then
                    return false
                end
            end
        end
        return original_isValid(self, square)
    end

    -- local original_rotateKey = ISDestroyCursor.rotateKey
    -- function ISDestroyCursor:rotateKey(key, _joypadTriggered)
    --     -- Reserved for rotation-based visual phase logic
    --     original_rotateKey(self, key, _joypadTriggered)
    -- end

    local original_render = ISDestroyCursor.render
    function ISDestroyCursor:render(x, y, z, square)
        ---@diagnostic disable-next-line: unnecessary-if
        if MAF and MAF.config.ISDestroyCursorProtection and MAFV and square then
            local ctx = MAFV:getVisualContext("DestroyCursorRender", nil, self.character, square)
            MAFV:processAction(ctx)
        end
        original_render(self, x, y, z, square)
    end

    -- local original_create = ISDestroyCursor.create
    -- function ISDestroyCursor:create(x, y, z, north, sprite)
    --     -- Reserved for final authority trigger before server execution
    --     original_create(self, x, y, z, north, sprite)
    -- end
end

return serverSidePatch
