-- Set to false to disable cursor hooks for testing the server :complete() method hooks
local JASM_CURSOR_HOOKS_ENABLED = true

local patches = {}

function patches.clientSidePatch()
    -- UI Guards (Client Side)
    local original_canPickUpMoveableInternal = ISMoveableSpriteProps.canPickUpMoveableInternal
    function ISMoveableSpriteProps:canPickUpMoveableInternal(_character, _square, _object, _isMulti)
        if JASM_CURSOR_HOOKS_ENABLED and _object and _object:getModData().isShop then
            return false
        end
        return original_canPickUpMoveableInternal(self, _character, _square, _object, _isMulti)
    end

    local original_canScrapObjectInternal = ISMoveableSpriteProps.canScrapObjectInternal
    function ISMoveableSpriteProps:canScrapObjectInternal(_result, _object)
        if JASM_CURSOR_HOOKS_ENABLED and _object and _object:getModData().isShop then
            ---@diagnostic disable-next-line: unnecessary-if
            if _result then
                _result.canScrap = false
            end
            return false
        end
        return original_canScrapObjectInternal(self, _result, _object)
    end

    -- Display Shop Tooltip
    local original_getInfoPanelDescription = ISMoveableSpriteProps.getInfoPanelDescription
    function ISMoveableSpriteProps:getInfoPanelDescription(infoTable, _object, _square)
        infoTable = original_getInfoPanelDescription(self, infoTable, _object, _square)
        if JASM_CURSOR_HOOKS_ENABLED and _object and _object:getModData().isShop then
            local bR, bG, bB = getCore():getBadHighlitedColor():getR(), getCore():getBadHighlitedColor():getG(), getCore():getBadHighlitedColor():getB()
            infoTable = ISMoveableSpriteProps.addLineToInfoTable(infoTable, "- " .. getTextOrNull("IGUI_JASM_Shop") or "is Shop", bR, bG, bB)
        end
        return infoTable
    end
end

return patches
