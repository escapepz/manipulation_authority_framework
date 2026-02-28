local patches = {}

function patches.clientSidePatch()
    local original_ISMoveablesAction_isValidObject = ISMoveablesAction.isValidObject
    function ISMoveablesAction:isValidObject()
        local MAF = _G.ManipulationAuthorityFramework
        if MAF and MAF.config.ISMoveablesActionProtection then
            local object = self.object
            if object and object:getModData().isShop then
                -- Block Pickup and Scrap as a direct detour (not event-based for performance)
                if self.mode == "pickup" or self.mode == "scrap" then
                    return false
                end
            end
        end
        return original_ISMoveablesAction_isValidObject(self)
    end
end

function patches.serverSidePatch()
    local original_ISMoveablesAction_getDuration = ISMoveablesAction.getDuration
    function ISMoveablesAction:getDuration()
        local MAF = _G.ManipulationAuthorityFramework
        if MAF and MAF.config.ISMoveablesActionProtection then
            local object = self.object
            if object and (self.mode == "pickup" or self.mode == "scrap") then
                local ctx = MAF:createContext("Moveables", self, object, self.character)
                -- Fire pre-action phase (registration/instance capture)
                MAF:processAction("pre", ctx)
            end
        end
        return original_ISMoveablesAction_getDuration(self)
    end

    local original_ISMoveablesAction_complete = ISMoveablesAction.complete
    function ISMoveablesAction:complete()
        local MAF = _G.ManipulationAuthorityFramework
        if MAF and MAF.config.ISMoveablesActionProtection then
            local object = self.object
            if object and (self.mode == "pickup" or self.mode == "scrap") then
                local ctx = MAF:createContext("Moveables", self, object, self.character)
                MAF:processAction("validate", ctx)

                if ctx.flags.rejected then
                    ---@diagnostic disable-next-line: unnecessary-if
                    if self.action then
                        self:stop()
                    end
                    return false
                end

                -- Run Vanilla Logic
                local result = original_ISMoveablesAction_complete(self)

                -- Fire Post-Action phase (Side-effects)
                if result ~= false then
                    MAF:processAction("post", ctx)
                end

                return result
            end
        end
        return original_ISMoveablesAction_complete(self)
    end
end

return patches
