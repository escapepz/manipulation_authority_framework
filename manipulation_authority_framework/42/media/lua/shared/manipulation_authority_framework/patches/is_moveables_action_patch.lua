local patches = {}

function patches.serverSidePatch()
    -- [Performance Intel]
    -- ISMoveablesAction:getDuration() is called many times (not just one time).
    -- To avoid performance issues and redundant calls, we don't process the 'pre' phase
    -- or set maxTime inside getDuration. The rule is to fire the 'pre' phase on creation and use :stop()
    -- to cancel the action, rather than manipulating getDuration().
    -- local original_ISMoveablesAction_getDuration = ISMoveablesAction.getDuration
    -- function ISMoveablesAction:getDuration()
    --     -- Ensure getDuration hooks only return a number.
    --     return original_ISMoveablesAction_getDuration(self)
    -- end

    local original_ISMoveablesAction_complete = ISMoveablesAction.complete
    function ISMoveablesAction:complete()
        local MAF = _G.ManipulationAuthorityFramework
        if MAF and MAF.config.ISMoveablesActionProtection then
            local object = self.object
            local mode = self.mode
            if object and (mode == "pickup" or mode == "scrap") then
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
