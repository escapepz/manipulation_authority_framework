local patches = {}

function patches.clientSidePatch()
    -- Add isValid hook for visual phase checking during action
    local original_ISMoveablesAction_isValidObject = ISMoveablesAction.isValidObject
    function ISMoveablesAction:isValidObject()
        local MAF = _G.ManipulationAuthorityFramework
        local MAFV = _G.ManipulationAuthorityFrameworkVisual
        if MAF and MAF.config.ISMoveablesActionProtection and MAFV then
            ---@cast self ISMoveablesAction
            local object = self.object
            local mode = self.mode
            ---@diagnostic disable-next-line: unnecessary-if
            if object and (mode == "pickup" or mode == "scrap") then
                local ctx = MAFV:getVisualContext(
                    "Moveables",
                    object,
                    self.character,
                    object:getSquare(),
                    mode
                )
                ctx.action = self
                MAFV:processAction(ctx)
                if ctx.flags.rejected then
                    return false
                end
            end
        end
        return original_ISMoveablesAction_isValidObject(self)
    end

    -- So we should regis the hook from both client and server
    -- local original_new = ISMoveablesAction.new
    -- function ISMoveablesAction:new(character, square, mode, origSpriteName, object, direction, item, moveCursor)
    --     local o = original_new(self, character, square, mode, origSpriteName, object, direction, item, moveCursor)
    --     local MAF = _G.ManipulationAuthorityFramework
    --     if MAF and MAF.config.ISMoveablesActionProtection then
    --         ---@diagnostic disable-next-line: unnecessary-if
    --         if o.object and (o.mode == "pickup" or o.mode == "scrap") then
    --             local ctx = MAF:createContext("Moveables", o, o.object, character)
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
