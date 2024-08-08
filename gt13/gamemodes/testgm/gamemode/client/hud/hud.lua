
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
        "EYES",
    },
    {
        "HEAD",
        "EYES",
        "EAR",
    },
}

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

local wep_show = false

function SelectWep(id)
    local list = ClGetWeaponsSlot(true, LocalPlayer())
    input.SelectWeapon( list[id] )
    GS_HUD.selected_wep = id

end

function SelectNextWep()
    local list = ClGetWeaponsSlot(true, LocalPlayer())
    local curid = table.KeyFromValue( list, LocalPlayer():GetActiveWeapon() )
    if curid < #list then
        SelectWep(curid+1)
    end
end

function SelectPrevWep()
    local list = ClGetWeaponsSlot(true, LocalPlayer())
    local curid = table.KeyFromValue( list, LocalPlayer():GetActiveWeapon() )
    if curid != 1 then
        SelectWep(curid - 1)
    end
end

function UpdateSelectedWep(id) -- if weapon selected another action (drop wep), called 
    SelectWep(id)
    wep_show = true
    timer.Create("wepselshow", 3, 1, function()
        wep_show = false
    end)
end

function GetSelectedWeapon()
    if LocalPlayer():Alive() then
        local list = LocalPlayer():GetWeapons()
        return table.KeyFromValue( list, LocalPlayer():GetActiveWeapon() )
    end
end

function GS_HUD.DrawHud() 
	surface.SetFont( "TargetID" )
	surface.SetTextColor( 255, 255, 255 )

    local H = ScrH()
    local W = ScrW()

    surface.SetDrawColor(25,25,175,200)

    if wep_show then
        local weaplist = ClGetWeaponsSlot(false, LocalPlayer())

        for i = 1, 4 do
            surface.DrawRect((W / 3.5 ) + (110 * i), H - (H / 8), 90, 90)
            surface.SetTextPos( ((W / 3.5 ) + (110 * i))+10, (H - (H / 8))+10) 
            surface.DrawText( i )
        end

        for i = 1,#weaplist do
            surface.SetTextPos( ((W / 3.5 ) + (110 * i))+10, (H - (H / 8))+30)
            surface.DrawText( weaplist[i] )
        end

        surface.SetDrawColor(255,255,255,255)

        local selected_wep = GetSelectedWeapon()
    
        if selected_wep != 0 then
            surface.DrawOutlinedRect( (W / 3.5 ) + (110 * GS_HUD.selected_wep), H - (H / 8), 90, 90, 3 )
        end
    end
    
    --[[
    for i = 1,2 do
        surface.DrawRect((W / 1.5 ) + (110 * i), H - (H / 8), 90, 90)
        surface.SetTextPos( ((W / 1.5 ) + (110 * i))+10, (H - (H / 8))+10) 
        surface.DrawText( i )
        if GS_ClPlyStat.init then
            surface.SetTextPos(((W / 1.5 ) + (110 * i))+10, (H - (H / 8))+30)
            surface.DrawText(GS_ClPlyStat:GetNameItemFromPocket(i))
        end
    end
    --]]

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
            
            --hunger level
            surface.SetDrawColor( 64, 64, 64, 255 )
            surface.DrawOutlinedRect( W - 100, 200, 20, 90, 1 )
            surface.SetDrawColor( GS_ClPlyStat:HungerColor():Unpack() )
            
            local hunger_val = math.floor((GS_ClPlyStat:HungerStatus() / 100) * 88)

            surface.DrawRect(W - 99, 201 + (88 - hunger_val), 18, hunger_val)
        end
    end

    surface.SetMaterial( hpicon[GS_ClPlyStat:GetHPStatIcon()])
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( W - 150, 500, 96, 96 )

end

function GS_HUD.SpectatorHud()
	surface.SetFont( "DermaLarge" )
	surface.SetTextColor( 255, 255, 255 )
    surface.SetTextPos((ScrW() / 2)-50, (ScrH() / 2) + 100)
    surface.DrawText( "Spectating" )
end


hook.Add("PlayerBindPress", "ActionButtonsdsd", function(ply, bind, pressed)
    if !ply:Alive() or ply:Team() != TEAM_PLY or ply:GetNWBool("Ragdolled") then 
        return
    end

    if bind == "invnext" then
        SelectNextWep()
    end

    if bind == "invprev" then
        SelectPrevWep()
    end
end)
