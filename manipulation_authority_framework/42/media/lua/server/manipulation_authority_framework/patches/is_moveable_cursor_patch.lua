local serverSidePatch = function()
    local MAF = _G.ManipulationAuthorityFramework
    local MAFV = _G.ManipulationAuthorityFrameworkVisual

    -- UI Guards (Client Side)
    local original_isValidCursor = ISMoveableCursor.isValid
    function ISMoveableCursor:isValid(square)
        -- Only check when picking up or scrapping
        if
            MAF
            and MAF.config.ISMoveableCursorProtection
            and (self.moveableMode == "pickup" or self.moveableMode == "scrap")
            and square
        then
            if MAFV then
                local objects = square:getObjects()
                for i = 0, objects:size() - 1 do
                    local object = objects:get(i)

                    -- Use pooled context for high-frequency visual check
                    local ctx = MAFV:getVisualContext(
                        "MoveableCursor",
                        object,
                        self.character,
                        square,
                        self.moveableMode
                    )
                    MAFV:processAction(ctx)

                    if ctx.flags.rejected then
                        return false
                    end
                end
            end
        end
        return original_isValidCursor(self, square)
    end

    local original_setMoveableMode = ISMoveableCursor.setMoveableMode
    function ISMoveableCursor:setMoveableMode(mode)
        -- Reserved for visual phase refresh on mode change
        original_setMoveableMode(self, mode)
    end

    local original_rotateKey = ISMoveableCursor.rotateKey
    function ISMoveableCursor:rotateKey(key, _joypadTriggered)
        -- Reserved for rotation-based visual phase logic
        original_rotateKey(self, key, _joypadTriggered)
    end

    local original_create = ISMoveableCursor.create
    function ISMoveableCursor:create(x, y, z, north, sprite)
        -- Reserved for final authority trigger before server execution (Pickup/Place/Scrap)
        original_create(self, x, y, z, north, sprite)
    end
end

return serverSidePatch
