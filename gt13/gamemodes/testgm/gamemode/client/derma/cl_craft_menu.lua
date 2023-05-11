--[[
    save list of crafts on sh_craft_list.lua
    openheere
]]

function CraftMenuOpen()
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 440)
    frame:Center()
    frame:SetTitle("Craft")
    frame:MakePopup()

    
	local categorySheet = vgui.Create( "DPropertySheet", frame )
    categorySheet:Dock(FILL)

    local tab1panel = vgui.Create( "DPanel" )

    local SheetItem = vgui.Create( "DButton", tab1panel )
    SheetItem:SetText( "Suicide" )
    SheetItem:SetConsoleCommand( "kill" )
    
    categorySheet:AddSheet( "Tab 1", tab1panel, "icon16/user.png", false, false, "Description of first tab")

end

concommand.Add("gs_craftmenu", CraftMenuOpen)