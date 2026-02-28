local patches = {}

function patches.clientSidePatch()
    -- Visual phase hooks in actions are redundant.

    -- So we should regis the hook from both client and server
    -- local original_new = ISDestroyStuffAction.new
    -- function ISDestroyStuffAction:new(character, item, cornerCounter)
    --     local o = original_new(self, character, item, cornerCounter)
    --     local MAF = _G.ManipulationAuthorityFramework
    --     if MAF and MAF.config.ISDestroyStuffActionProtection then
    --         ---@diagnostic disable-next-line: unnecessary-if
    --         if o.item then
    --             local ctx = MAF:createContext("DestroyStuff", o, o.item, character)
    --             -- Fire pre-action phase (registration/instance capture)
    --             MAF:processAction("pre", ctx)
    --             -- Note: if we needed to override maxTime, we would set o.maxTime here on creation
    --             -- rather than inside getDuration().
    --         end
    --     end
    --     return o
    -- end
end

function patches.serverSidePatch()
    -- [Performance Intel]
    -- ISDestroyStuffAction:getDuration() is called many times (not just one time).
    -- To avoid performance issues and redundant calls, we don't process the 'pre' phase
    -- or set maxTime inside getDuration. The rule is to fire the 'pre' phase on creation and use :stop()
    -- to cancel the action, rather than manipulating getDuration().
    -- local original_getDuration = ISDestroyStuffAction.getDuration
    -- function ISDestroyStuffAction:getDuration()
    --     -- Ensure getDuration hooks only return a number.
    --     return original_getDuration(self)
    -- end

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
                        self:stop() -- ISDestroyStuffAction does not have :forceStop(), use :stop() instead
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
