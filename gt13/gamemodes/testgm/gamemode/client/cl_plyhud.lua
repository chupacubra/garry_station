GS_HUD = {}

--[[
hat/mask
backpack/vest/
poyas/gloves
]]

local HUD_EQUEIP = {
    {
        "BELT",
        "KEYCARD",
        "PDA",
    },
    {
        "BACKPACK",
        "VEST",
        "GLOVES",
    },
    {
        "HEAD",
        "MASK",
        "EAR",
    },
}
local hp = Material( "health_1" )

local hpicon = {
    Material( "health_1" ),
    Material( "health_2" ),
    Material( "health_3" ),
    Material( "health_4" ),
    Material( "health_5" ),
    Material( "health_6" ),
    Material( "health_7" ),
    Material( "health_8" ),
}
function GS_HUD.DrawHud() 

	surface.SetFont( "TargetID" )
	surface.SetTextColor( 255, 255, 255 )


    -- draw slots
    local H = ScrH()
    local W = ScrW()
    surface.SetDrawColor(25,25,175,200)
    local weaplist = GS_ClPlyStat:GetWeaponsSlot()

    for i = 1, 4 do
        surface.DrawRect((W / 3.5 ) + (110 * i), H - (H / 8), 90, 90)
        surface.SetTextPos( ((W / 3.5 ) + (110 * i))+10, (H - (H / 8))+10) 
        surface.DrawText( i )
    end

    for i = 1,#weaplist do
        surface.SetTextPos( ((W / 3.5 ) + (110 * i))+10, (H - (H / 8))+30)
        surface.DrawText( weaplist[i] )
    end

    for i = 1,2 do
        surface.DrawRect((W / 1.5 ) + (110 * i), H - (H / 8), 90, 90)
        surface.SetTextPos( ((W / 1.5 ) + (110 * i))+10, (H - (H / 8))+10) 
        surface.DrawText( i )
        if GS_ClPlyStat.init then
            surface.SetTextPos(((W / 1.5 ) + (110 * i))+10, (H - (H / 8))+30)
            surface.DrawText(GS_ClPlyStat:GetNameItemFromPocket(i))
        end
    end

    surface.SetDrawColor(255,255,255,240)
    for i = 1,4 do
        surface.DrawOutlinedRect( (W / 3.5 ) + (110 * i), H - (H / 8), 90, 90, 3 )
    end


    --]]
    --draw hp


    if GS_ClPlyStat then
        if GS_ClPlyStat.init then
            local i = 1
            for k,v in pairs(GS_ClPlyStat.hp) do
                surface.SetTextPos(W - 100,500-(i*20)) 
                surface.SetTextColor(GetProcentColor(v))
                surface.SetTextPos(W - 150,500-(i*25))
                surface.DrawText( k .. " ".. v .. " %" )
                i = i + 1
            end
        end
    end
    surface.SetMaterial( hpicon[GS_ClPlyStat:GetHPStatIcon()])
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( W - 150, 500, 96, 96 )

end

