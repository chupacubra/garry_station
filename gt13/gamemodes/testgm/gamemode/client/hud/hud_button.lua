local PANEL = {}

function PANEL:Init()
    self:SetSize( 100, 100 )
    self:Center()
    self:SetText_Base( "" )
    self.text  = ""
    self.text2 = ""
    self.bcolor = Color(25,25,175,200)
end

function PANEL:SetColorB(color)
    self.bcolor = color or self.bcolor
end

function PANEL:Paint( w, h )
    surface.SetFont( "TargetID" )
    surface.SetTextColor( 255, 255, 255 )
    surface.SetDrawColor( self.bcolor:Unpack() )
    surface.DrawRect(0, 0, 90, 90)
    surface.SetTextPos(0,0) 
    surface.DrawText( self.text )
    surface.SetTextPos(0,15)
    surface.DrawText( self.text2 )
end

PANEL.SetText_Base = FindMetaTable( "Panel" ).SetText

function PANEL:SetText(a, b)
    self.text  = a or ""
    self.text2 = b or ""

    self.Text = ""
end

vgui.Register( "gt_button", PANEL, "DButton" )