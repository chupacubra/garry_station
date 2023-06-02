--[[
    save list of crafts on sh_craft_list.lua
    openheere
]]

surface.CreateFont( "GS_Tahoma", {
	font = "Tahoma",
	extended = false,
	size = 14,
	--weight = 800,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	--underline = true,
} )

function CraftMenuOpen()
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 440)
    frame:Center()
    frame:SetTitle("Craft")
    frame:MakePopup()

    local PLabel = vgui.Create( "DLabel" , frame)
    PLabel:SetPos(5, 30)
    PLabel:SetSize(164,20)
    PLabel:SetFont("GS_Tahoma")
    PLabel:SetColor(Color(0,0,0))
    PLabel:SetText("Person information")

    --frame:SetFont("GS_Tahoma")
    
	local categorySheet = vgui.Create( "DPropertySheet", frame )
    categorySheet:Dock(FILL)

    local tab1panel = vgui.Create( "DPanel" )

    local SheetItem = vgui.Create( "DButton", tab1panel )
    SheetItem:SetText( "Suicide" )
    SheetItem:SetConsoleCommand( "kill" )
    
    categorySheet:AddSheet( "Tab 1", tab1panel, "icon16/user.png", false, false, "Description of first tab")

end

concommand.Add("gs_craftmenu", CraftMenuOpen)