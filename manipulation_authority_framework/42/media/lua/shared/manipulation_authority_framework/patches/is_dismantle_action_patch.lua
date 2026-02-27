local patches = {}

function patches.clientSidePatch()
    -- Visual phase hooks in actions are redundant; using Cursor/UI hooks instead.
end

function patches.serverSidePatch()
    local MAF = _G.ManipulationAuthorityFramework

    local original_ISDismantleAction_getDuration = ISDismantleAction.getDuration
    function ISDismantleAction:getDuration()
        if MAF.config.ISDismantleActionProtection then
            local object = self.thumpable
            ---@diagnostic disable-next-line: unnecessary-if
            if object then
                local ctx = MAF:createContext("Dismantle", self, object, self.character)
                -- Fire pre-action phase (solely to expose action instance to rules)
                MAF:processAction("pre", ctx)
            end
        end
        return original_ISDismantleAction_getDuration(self)
    end

    local original_ISDismantleAction_complete = ISDismantleAction.complete
    function ISDismantleAction:complete()
        if MAF.config.ISDismantleActionProtection then
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
