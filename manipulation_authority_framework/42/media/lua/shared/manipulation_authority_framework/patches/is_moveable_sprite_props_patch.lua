local patches = {}

function patches.clientSidePatch()
    -- UI Guards (Client Side)
    local original_canPickUpMoveable = ISMoveableSpriteProps.canPickUpMoveable
    function ISMoveableSpriteProps:canPickUpMoveable(_character, _square, _object)
        local MAF = _G.ManipulationAuthorityFramework
        local MAFV = _G.ManipulationAuthorityFrameworkVisual
        InfoPanelFlags.MAF_rejected = nil
        InfoPanelFlags.MAF_reason = nil

        if MAF and MAF.config.ISMoveableSpritePropsProtection and MAFV and _object then
            local ctx = MAFV:getVisualContext("PickUpMoveable", _object, _character, _square, nil)
            ctx.action = self
            MAFV:processAction(ctx)
            if ctx.flags.rejected then
                InfoPanelFlags.MAF_rejected = true
                InfoPanelFlags.MAF_reason = ctx.flags.reason or "Protected by Authority"
                return false
            end
        end
        return original_canPickUpMoveable(self, _character, _square, _object)
    end

    local original_canScrapObjectInternal = ISMoveableSpriteProps.canScrapObjectInternal
    function ISMoveableSpriteProps:canScrapObjectInternal(_result, _object)
        local MAF = _G.ManipulationAuthorityFramework
        local MAFV = _G.ManipulationAuthorityFrameworkVisual
        InfoPanelFlags.MAF_rejected = nil
        InfoPanelFlags.MAF_reason = nil

        ---@diagnostic disable-next-line: unnecessary-if
        if MAF and MAF.config.ISMoveableSpritePropsProtection and MAFV and _object then
            local ctx =
                MAFV:getVisualContext("ScrapMoveable", _object, nil, _object:getSquare(), nil)
            ctx.action = self
            MAFV:processAction(ctx)
            if ctx.flags.rejected then
                ---@diagnostic disable-next-line: unnecessary-if
                if _result then
                    _result.canScrap = false
                end
                InfoPanelFlags.MAF_rejected = true
                InfoPanelFlags.MAF_reason = ctx.flags.reason or "Protected by Authority"
                return false
            end
        end
        return original_canScrapObjectInternal(self, _result, _object)
    end

    -- Display Tooltip (Integrated with Visual Authority via InfoPanelFlags)
    local original_getInfoPanelDescription = ISMoveableSpriteProps.getInfoPanelDescription
    function ISMoveableSpriteProps:getInfoPanelDescription(_square, _object, _player, _mode)
        ---@diagnostic disable: assign-type-mismatch, param-type-mismatch
        local infoTable = original_getInfoPanelDescription(self, _square, _object, _player, _mode)
            or {}

        ---@diagnostic disable-next-line: unnecessary-if
        if InfoPanelFlags.MAF_rejected then
            local bR, bG, bB =
                getCore():getBadHighlitedColor():getR(),
                getCore():getBadHighlitedColor():getG(),
                getCore():getBadHighlitedColor():getB()

            local updatedTable = ISMoveableSpriteProps.addLineToInfoTable(
                infoTable,
                "- " .. (InfoPanelFlags.MAF_reason or "Protected by Authority"),
                bR,
                bG,
                bB
            )

            ---@diagnostic disable-next-line: unnecessary-if
            if updatedTable then
                infoTable = updatedTable
            end
        end

        ---@diagnostic enable: assign-type-mismatch, param-type-mismatch
        return infoTable
    end
end

return patches
