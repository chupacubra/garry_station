
local WeaponSelector = {}
WeaponSelector.ActiveWeapon = nil
WeaponSelector.OldWeapon    = nil
WeaponSelector.LastChange   = -1

local WS_SHOWTIME = 3
local WS_SIZE = 150

/*
local function WSPanel()



    local panel = vgui.Create("DPanel")
    panel:SetSize(WH_SIZE)
    panel:SetPos(500, 500)
    panel:SetPaintedManually( true )
    //panel:MakePopup()
    //panel:SetVisible( true )
    function panel:GetActiveTab() return nil end
    //function panel:Paint(w, h)
        //derma.SkinHook( "Paint", "PropertySheet", self, w, h )
        /*if self.IsWepSelected then
            draw.RoundedBox( 4, 5, 5, w-10, h-10, Color( 255, 255, 255 ) )
        end*/
    //end
 /*

    panel.IsWepSelected = false


    local panel = vgui.Create("DPanel")
    //panel:SetSize(WH_SIZE, WH_SIZE)
    //panel:SetPos(500, 500)
    return panel
end

function WeaponSelector:Init()
    self.Panels = {
        WSPanel(),
        WSPanel()
    }  
    
    local w, h = ScrW(), ScrH()
    for i = 1, 2 do
        local x = (155) * math.cos( math.pi * i ) + (1-i) * (145)
        local panel = self.Panels[i]
        panel:SetPos(w/2 + x, h - 160)
        panel:SetSize(WH_SIZE, WH_SIZE)
        //self.Panels[i]:SetPos(w/2, h/2)
    end
    
end

function WeaponSelector:ChangeWeapon(old, new)
    self.ActiveWeapon = new
    self.OldWeapon = old
    self.LastChange = CurTime()
end


function WeaponSelector:Draw()
    /*
 
    local oldW, oldH = ScrW(), ScrH()
    render.SetViewPort( 0, 100, 50, 50 )
    cam.Start2D()
        //surface.SetDrawColor( 255, 255, 255 )
        //surface.DrawLine( 10, 10, 100, 100 )
            for k, pnl in pairs(self.Panels) do
    //    pnl:Paint(150, 150)
        //print(pnl:GetPos())
        //pnl:Paint(150, 150)
        pnl:PaintManual()
            end
    cam.End2D()
    render.SetViewPort( 0, 0, oldW, oldH )
    */
//end
/*
WeaponSelector:Init() 
hook.Add("PlayerSwitchWeapon", "ChangeWeaponSelector", function(ply, old, new)
    WeaponSelector:ChangeWeapon(old, new)
end)

hook.Add("HUDPaint", "DrawWeaponSelector", function()
    WeaponSelector:Draw()
end)
*/

local keybuttons = {
    [KEY_1] = 1,
    [KEY_2] = 2,
}

hook.Add( "PlayerButtonDown", "FastChangeWeapon", function( ply, key )
    if player_manager.GetPlayerClass( ply ) != "gs_human" then return end
	if !(key == KEY_1 or key == KEY_2) then return end

    local weaps = ply:GetWeapons()
    local id = keybuttons[key]
    input.SelectWeapon(weaps[id])
end)
