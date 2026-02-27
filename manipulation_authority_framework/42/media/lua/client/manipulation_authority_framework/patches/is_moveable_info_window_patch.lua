local clientSidePatch = function()
    local MAFV = _G.ManipulationAuthorityFrameworkVisual

    local original_render = ISMoveableInfoWindow.render
    function ISMoveableInfoWindow:render()
        original_render(self)
        
        -- Fire visual phase for the info window
        if self.square and MAFV then
            local ctx = MAFV:getVisualContext("MoveableInfoWindow", nil, self.character, self.square)
            MAFV:processAction(ctx)
            
            -- Rejections can be handled by listeners drawing overlay text via self:drawText()
        end
    end
end

return clientSidePatch
