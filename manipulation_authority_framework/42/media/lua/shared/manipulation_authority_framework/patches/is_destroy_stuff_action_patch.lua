local patches = {}

function patches.clientSidePatch()
    -- Visual phase hooks in actions are redundant.
end

function patches.serverSidePatch()
    local original_getDuration = ISDestroyStuffAction.getDuration
    function ISDestroyStuffAction:getDuration()
        local MAF = _G.ManipulationAuthorityFramework
        if MAF and MAF.config.ISDestroyStuffActionProtection then
            local object = self.item
            ---@diagnostic disable-next-line: unnecessary-if
            if object then
                local ctx = MAF:createContext("DestroyStuff", self, object, self.character)
                -- Fire pre-action phase (registration/instance capture)
                MAF:processAction("pre", ctx)
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
                local ctx = MAF:createContext("DestroyStuff", self, object, self.character)
                MAF:processAction("validate", ctx)

                if ctx.flags.rejected then
                    ---@diagnostic disable-next-line: unnecessary-if
                    if self.action then
                        self:forceStop()
                    end
                    return false
                end

                -- Run Vanilla Logic
                local result = original_complete(self)

                -- Fire Post-Action phase (Side-effects)
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
