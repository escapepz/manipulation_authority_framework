local clientSidePatch = function()
    local MAFV = _G.ManipulationAuthorityFrameworkVisual

    -- Hooking the tooltip for the moveable mode icons (Pickup, Place, Rotate, Scrap)
    local original_render = ISMoveablesIconToolTip.render
    function ISMoveablesIconToolTip:render()
        original_render(self)

        -- Fire visual phase for the icon tooltip
        if MAFV then
            -- We pass data = nil as mode is often implicit in the context of which icon is hovered
            -- but listeners can check self.subText or other context
            local ctx = MAFV:getVisualContext("MoveablesIconToolTip", nil, getPlayer())
            MAFV:processAction(ctx)

            if ctx.flags.rejected then
                local bR, bG, bB =
                    getCore():getBadHighlitedColor():getR(),
                    getCore():getBadHighlitedColor():getG(),
                    getCore():getBadHighlitedColor():getB()
                self:drawText(
                    "- " .. (ctx.flags.reason or "Blocked by Authority"),
                    8,
                    self.height - 15,
                    bR,
                    bG,
                    bB,
                    1,
                    UIFont.Small
                )
            end
        end
    end
end

return clientSidePatch
