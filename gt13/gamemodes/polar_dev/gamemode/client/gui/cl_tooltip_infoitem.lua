local PANEL = {}

function PANEL:Init()
    self:SetAlpha(0)
    self:AlphaTo( 200, 0.2, 0, function() self:SetEnabled(true) end)
    self:SetTextColor( Color( 0, 0, 0))
    self:SetSize(400, 400)

    timer.Simple(0, function()
        if self.TargetPanel then
            local item = self.TargetPanel.Item
            print(item)
            if IsValid(item) then
                self:SetItem(item)
            end
        end
    end)

end

function PANEL:GetActiveTab()
    return nil
end

function PANEL:Paint(w, h)
    derma.SkinHook( "Paint", "PropertySheet", self, w, h )
    if self.Item then
        draw.SimpleText( self.Item.Name,"GModToolSubtitle", 10, 10, self:GetTextColor() )
        draw.SimpleText( self.Item.Desc,"GModToolSubtitle", 10, 50, self:GetTextColor() )

    end
end

function PANEL:PaintOver( w, h ) end


function PANEL:ClearItem()
end

function PANEL:SetContents( panel, bDelete )

	panel:SetParent( self )

	self.Contents = panel
	self.DeleteContentsOnClose = bDelete or false
	self.Contents:SizeToContents()
	self:InvalidateLayout( true )

	self.Contents:SetVisible( false )

end

// need auto resize panel 
function PANEL:PerformLayout()
    // rewrite this
	if ( IsValid( self.Contents ) ) then

		self:SetWide( self.Contents:GetWide() + 8 )
		self:SetTall( self.Contents:GetTall() + 8 )
		self.Contents:SetPos( 4, 4 )
		self.Contents:SetVisible( true )

	else

		local w, h = self:GetContentSize()
		self:SetSize( w + 8, h + 6 )
		self:SetContentAlignment( 5 )

	end

end

function PANEL:SetItem(item)
    self.Item = item
    
    local pnl = vgui.Create("DPanel")
    pnl:SetSize(150, 100)
    // rework this

    function pnl:Paint() end
    
    self:SetContents(pnl)
end

function PANEL:Close()
    self:AlphaTo(0,0.2, 0)
    timer.Simple(0.2, function() self:Remove() end )
end

vgui.Register("GUITooltip", PANEL, "DTooltip")