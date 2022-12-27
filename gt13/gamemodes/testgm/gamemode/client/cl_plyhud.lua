HUD = {}

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

function HUD.DrawHud()
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


    surface.SetDrawColor(255,255,255,240)
    for i = 1,4 do
        surface.DrawOutlinedRect( (W / 3.5 ) + (110 * i), H - (H / 8), 90, 90, 3 )
    end

    --draw equipment
    surface.SetDrawColor(25,25,175,200)
    for i = 1,3 do
        for k,v in pairs(HUD_EQUEIP[i]) do
            surface.DrawRect(10 + (110 * (k-1)), (H - ((H / 8) + ((i-1) * 110))), 90, 90)
            surface.SetTextPos(10 + (110 * (k-1)), (H - ((H / 8) + ((i-1) * 110)))) 
            surface.DrawText( v )

            if GS_ClPlyStat then
                if GS_ClPlyStat.init then
                    if GS_ClPlyStat.equipment[v] != 0 then
                        surface.SetTextPos(10 + (110 * (k-1)), (H - ((H / 8) + ((i-1) * 110) - 15)))
                        --surface.DrawText( GS_ClPlyStat.equipment[v] )
                        surface.SetTextPos(10 + (110 * (k-1)), (H - ((H / 8) + ((i-1) * 110) - 30)))
                        surface.DrawText(GS_ClPlyStat:GetEquipName(v))
                    end
                end
            end

        end
    end

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

end

