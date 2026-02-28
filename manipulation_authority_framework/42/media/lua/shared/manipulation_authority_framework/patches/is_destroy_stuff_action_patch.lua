local patches = {}

function patches.serverSidePatch()
    -- [Performance Intel]
    -- ISDestroyStuffAction:getDuration() is called many times (not just one time).
    -- We can return 1 here if the manipulation is rejected by MAF, allowing the
    -- action to quickly "complete" and be stopped by the server-side validator.
    -- The actual destruction prevention is handled in :complete().
    -- Should be lightweight
    -- Should return only number
    local original_getDuration = ISDestroyStuffAction.getDuration
    function ISDestroyStuffAction:getDuration()
        local MAF = _G.ManipulationAuthorityFramework
        if MAF and MAF.config.ISDestroyStuffActionProtection then
            local object = self.item
            ---@diagnostic disable-next-line: unnecessary-if
            if object then
                local ctx = MAF:createContext("DestroyStuff", self, object, self.character)
                MAF:processAction("validate", ctx)

                if ctx.flags.rejected then
                    return 1
                end
            end
        end

        return original_getDuration(self)
    end

    local original_complete = ISDestroyStuffAction.complete
    function ISDestroyStuffAction:complete()
        local MAF = _G.ManipulationAuthorityFramework
        if MAF and MAF.config.ISDestroyStuffActionProtection then
            local object = self.item
            ---@diagnostic disable-next-line: unnecessary-if
            if object then
                -- pre phase should be here
                local ctx = MAF:createContext("DestroyStuff", self, object, self.character)
                MAF:processAction("pre", ctx)

                if ctx.flags.rejected then
                    ---@diagnostic disable-next-line: unnecessary-if
                    if self.action then
                        self:stop() -- ISDestroyStuffAction does not have :forceStop(), use :stop() instead
                        -- self:forceCancel()
                        -- self:forceStop()
                    end
                    return false
                end

                -- Run Vanilla Logic
                local result = original_complete(self)

                -- Fire Post-Action phase (Side-effects)
                -- Okay, no call post phase if result false for now,
                -- if you want strict call, use it in pre phase then
                -- designed to be lightweight framework
                if result ~= false then
                    MAF:processAction("post", ctx)
                end

                return result
            end
        end
        return original_complete(self)
    end
end

return patches
