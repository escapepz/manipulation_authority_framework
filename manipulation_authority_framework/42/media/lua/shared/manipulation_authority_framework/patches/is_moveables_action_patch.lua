local patches = {}

function patches.serverSidePatch()
    -- [Performance Intel]
    -- ISMoveablesAction:getDuration() is called many times (not just one time).
    -- We can return 1 here if the manipulation is rejected by MAF, allowing the
    -- action to quickly "complete" and be stopped by the server-side validator.
    -- The actual moveable prevention is handled in :complete().
    -- Should be lightweight
    -- Should return only number
    local original_ISMoveablesAction_getDuration = ISMoveablesAction.getDuration
    function ISMoveablesAction:getDuration()
        local MAF = _G.ManipulationAuthorityFramework
        if MAF and MAF.config.ISMoveablesActionProtection then
            local object = self.object
            local mode = self.mode
            if object and (mode == "pickup" or mode == "scrap") then
                local ctx = MAF:createContext("Moveables", self, object, self.character)
                MAF:processAction("validate", ctx)

                if ctx.flags.rejected then
                    return 1
                end
            end
        end

        return original_ISMoveablesAction_getDuration(self)
    end

    local original_ISMoveablesAction_complete = ISMoveablesAction.complete
    function ISMoveablesAction:complete()
        local MAF = _G.ManipulationAuthorityFramework
        if MAF and MAF.config.ISMoveablesActionProtection then
            local object = self.object
            local mode = self.mode
            if object and (mode == "pickup" or mode == "scrap") then
                -- pre phase should be here
                local ctx = MAF:createContext("Moveables", self, object, self.character)
                MAF:processAction("pre", ctx)

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
