local serverSidePatch = function()
    local MAF = _G.ManipulationAuthorityFramework

    local original_canDestroy = ISDestroyCursor.canDestroy
    function ISDestroyCursor:canDestroy(object)
        -- Direct detour for sandbox toggle (not event-based for performance on highlight)
        if MAF.config.ISDestroyCursorProtection then
            if object and object:getModData().isShop then
                return false
            end
        end
        return original_canDestroy(self, object)
    end

    local original_isValid = ISDestroyCursor.isValid
    function ISDestroyCursor:isValid(square)
        ---@diagnostic disable-next-line: unnecessary-if
        if MAF.config.ISDestroyCursorProtection and square then
            local MAFV = _G.ManipulationAuthorityFrameworkVisual
            if MAFV then
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
        end
        return original_isValid(self, square)
    end

    local original_rotateKey = ISDestroyCursor.rotateKey
    function ISDestroyCursor:rotateKey(key, _joypadTriggered)
        -- Reserved for rotation-based visual phase logic
        original_rotateKey(self, key, _joypadTriggered)
    end

    local original_render = ISDestroyCursor.render
    function ISDestroyCursor:render(x, y, z, square)
        -- Hook here for additional visual feedback if valid/invalid
        original_render(self, x, y, z, square)
    end

    local original_create = ISDestroyCursor.create
    function ISDestroyCursor:create(x, y, z, north, sprite)
        -- Reserved for final authority trigger before server execution
        original_create(self, x, y, z, north, sprite)
    end
end

return serverSidePatch
