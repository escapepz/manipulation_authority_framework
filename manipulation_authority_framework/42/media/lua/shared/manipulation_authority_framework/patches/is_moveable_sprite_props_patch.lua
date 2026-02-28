local patches = {}

function patches.clientSidePatch()
    -- UI Guards (Client Side)
    local original_canPickUpMoveableInternal = ISMoveableSpriteProps.canPickUpMoveableInternal
    function ISMoveableSpriteProps:canPickUpMoveableInternal(_character, _square, _object, _isMulti)
        local MAF = _G.ManipulationAuthorityFramework
        if
            MAF
            and MAF.config.ISMoveableSpritePropsProtection
            and _object
            and _object:getModData().isShop
        then
            return false
        end
        return original_canPickUpMoveableInternal(self, _character, _square, _object, _isMulti)
    end

    local original_canScrapObjectInternal = ISMoveableSpriteProps.canScrapObjectInternal
    function ISMoveableSpriteProps:canScrapObjectInternal(_result, _object)
        local MAF = _G.ManipulationAuthorityFramework
        if
            MAF
            and MAF.config.ISMoveableSpritePropsProtection
            and _object
            and _object:getModData().isShop
        then
            ---@diagnostic disable-next-line: unnecessary-if
            if _result then
                _result.canScrap = false
            end
            return false
        end
        return original_canScrapObjectInternal(self, _result, _object)
    end

    -- Display Tooltip (Integrated with Visual Authority)
    local original_getInfoPanelDescription = ISMoveableSpriteProps.getInfoPanelDescription
    function ISMoveableSpriteProps:getInfoPanelDescription(_square, _object, _player, _mode)
        ---@diagnostic disable: assign-type-mismatch, param-type-mismatch
        local infoTable = original_getInfoPanelDescription(self, _square, _object, _player, _mode)
            or {}

        local MAFV = _G.ManipulationAuthorityFrameworkVisual
        ---@diagnostic disable-next-line: unnecessary-if
        if MAFV and _object then
            local ctx =
                MAFV:getVisualContext("MoveableSpriteProps", _object, _player, _square, _mode)
            MAFV:processAction(ctx)

            if ctx.flags.rejected then
                local bR, bG, bB =
                    getCore():getBadHighlitedColor():getR(),
                    getCore():getBadHighlitedColor():getG(),
                    getCore():getBadHighlitedColor():getB()
                local updatedTable = ISMoveableSpriteProps.addLineToInfoTable(
                    infoTable,
                    "- " .. (ctx.flags.reason or "Protected by Authority"),
                    bR,
                    bG,
                    bB
                )
                ---@diagnostic disable-next-line: unnecessary-if
                if updatedTable then
                    infoTable = updatedTable
                end
            end
        end
        ---@diagnostic enable: assign-type-mismatch, param-type-mismatch
        return infoTable
    end
end

return patches
