local patches = {}

-- The old ISDismantleAction
function patches.serverSidePatch()
    local MAF = _G.ManipulationAuthorityFramework

    -- [Performance Intel]
    -- ISDismantleAction:getDuration() is called many times (not just one time).
    -- We can return 1 here if the manipulation is rejected by MAF, allowing the
    -- action to quickly "complete" and be stopped by the server-side validator.
    -- The actual dismantle prevention is handled in :complete().
    -- Should be lightweight
    -- Should return only number
    local original_ISDismantleAction_getDuration = ISDismantleAction.getDuration
    function ISDismantleAction:getDuration()
        -- Ensure we only run validation once per action instance
        if self.maf_ctx then
            return self.maf_ctx.flags.rejected and 1 or original_ISDismantleAction_getDuration(self)
        end

        if MAF and MAF.config.ISDismantleActionProtection then
            local object = self.thumpable
            ---@diagnostic disable-next-line: unnecessary-if
            if object then
                local ctx = MAF:createContext("Dismantle", self, object, self.character)
                MAF:processAction("validate", ctx)
                self.maf_ctx = ctx -- Cache context

                if ctx.flags.rejected then
                    return 1
                end
            end
        end

        return original_ISDismantleAction_getDuration(self)
    end

    local original_ISDismantleAction_complete = ISDismantleAction.complete
    function ISDismantleAction:complete()
        if MAF and MAF.config.ISDismantleActionProtection then
            local object = self.thumpable
            ---@diagnostic disable-next-line: unnecessary-if
            if object then
                -- Re-use cached context if available, otherwise create new
                local ctx = self.maf_ctx
                    or MAF:createContext("Dismantle", self, object, self.character)
                MAF:processAction("pre", ctx)

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
