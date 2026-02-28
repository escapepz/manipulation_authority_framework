local patches = {}

function patches.serverSidePatch()
    -- [Performance Intel]
    -- ISDismantleAction:getDuration() is called many times (not just one time).
    -- To avoid performance issues and redundant calls, we don't process the 'pre' phase
    -- or set maxTime inside getDuration. The rule is to fire the 'pre' phase on creation and use :stop()
    -- to cancel the action, rather than manipulating getDuration().
    -- local original_ISDismantleAction_getDuration = ISDismantleAction.getDuration
    -- function ISDismantleAction:getDuration()
    --     -- Ensure getDuration hooks only return a number.
    --     return original_ISDismantleAction_getDuration(self)
    -- end

    local original_ISDismantleAction_complete = ISDismantleAction.complete
    function ISDismantleAction:complete()
        local MAF = _G.ManipulationAuthorityFramework
        if MAF and MAF.config.ISDismantleActionProtection then
            local object = self.thumpable
            ---@diagnostic disable-next-line: unnecessary-if
            if object then
                local ctx = MAF:createContext("Dismantle", self, object, self.character)
                MAF:processAction("validate", ctx)

                if ctx.flags.rejected then
                    ---@diagnostic disable-next-line: unnecessary-if
                    if self.action then
                        self:stop()
                    end
                    return false
                end

                -- Run Vanilla Logic
                local result = original_ISDismantleAction_complete(self)

                -- Fire Post-Action phase (Side-effects)
                -- Only fires if vanilla logic didn't return false (unlikely in this class but safe)
                if result ~= false then
                    MAF:processAction("post", ctx)
                end

                return result
            end
        end
        return original_ISDismantleAction_complete(self)
    end
end

return patches
