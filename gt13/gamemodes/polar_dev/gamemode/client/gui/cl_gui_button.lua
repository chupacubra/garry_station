local PANEL = {}

function PANEL:Init()
    self.Hovering = false
    self:SetAlpha(0)
    self:SetEnabled(false)
    self:AlphaTo( 200, 0.2, 0, function() self:SetEnabled(true) end)
    self:SetMouseInputEnabled(true)
end

function PANEL:SetItem()

end

function PANEL:ClearItem()

end

function PANEL:Think()
    if !self:IsEnabled() then return end
    if self:IsHovered() or self:IsChildHovered() then
        if !self.Hovering then
            self:AlphaTo(255, 0.1,0)
            self.Hovering = true
            print("123")
        end
    else
        if self.Hovering then
            self:AlphaTo(200, 0.1,0)
            self.Hovering = false
        end
    end
end

//function PANEL:OnRemove()
//end

function PANEL:Close()
    self:AlphaTo(0,0.2, 0)
    timer.Simple(0.2, function() self:Remove() end )
end

vgui.Register("GUIButton", PANEL, "DPropertySheet")