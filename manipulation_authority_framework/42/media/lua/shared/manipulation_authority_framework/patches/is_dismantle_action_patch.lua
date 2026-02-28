local patches = {}

function patches.clientSidePatch()
    -- Visual phase hooks in actions are redundant; using Cursor/UI hooks instead.

    -- Add isValid hook for visual phase checking during action
    local original_ISDismantleAction_isValid = ISDismantleAction.isValid
    function ISDismantleAction:isValid()
        local MAF = _G.ManipulationAuthorityFramework
        local MAFV = _G.ManipulationAuthorityFrameworkVisual
        if MAF and MAF.config.ISDismantleActionProtection and MAFV then
            local object = self.thumpable
            ---@diagnostic disable-next-line: unnecessary-if
            if object then
                local ctx = MAFV:getVisualContext(
                    "Dismantle",
                    object,
                    self.character,
                    object:getSquare(),
                    nil
                )
                ctx.action = self
                MAFV:processAction(ctx)
                if ctx.flags.rejected then
                    return false
                end
            end
        end
        return original_ISDismantleAction_isValid(self)
    end

    -- So we should regis the hook from both client and server
    -- local original_new = ISDismantleAction.new
    -- function ISDismantleAction:new(character, thumpable)
    --     local o = original_new(self, character, thumpable)
    --     local MAF = _G.ManipulationAuthorityFramework
    --     if MAF and MAF.config.ISDismantleActionProtection then
    --         ---@diagnostic disable-next-line: unnecessary-if
    --         if o.thumpable then
    --             local ctx = MAF:createContext("Dismantle", o, o.thumpable, character)
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
