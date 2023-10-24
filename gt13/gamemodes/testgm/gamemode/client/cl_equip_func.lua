--[[
function GetCoordinates(ent) -- put this on client
    local min,max = ent:OBBMins(),ent:OBBMaxs()
    local corners = {
        Vector(min.x,min.y,min.z),
        Vector(min.x,min.y,max.z),
        Vector(min.x,max.y,min.z),
        Vector(min.x,max.y,max.z),
        Vector(max.x,min.y,min.z),
        Vector(max.x,min.y,max.z),
        Vector(max.x,max.y,min.z),
        Vector(max.x,max.y,max.z)
    }

    local minx, miny, maxx, maxy = ScrW() * 2, ScrH() * 2, 0, 0

    for _, corner in pairs(corners) do
        local screen = ent:LocalToWorld(corner):ToScreen()
        minx,miny = math.min(minx, screen.x), math.min(miny, screen.y)
        maxx,maxy = math.max(maxx, screen.x), math.max(maxy, screen.y)
    end

    return {minx,miny,maxx,maxy}
end
--]]
function GetCoordinates(ent) -- put this on client
    local min,max = ent:OBBMins(),ent:OBBMaxs()
    local corners = {
        ent:LocalToWorld(Vector(min.x,min.y,min.z)):ToScreen(),
        ent:LocalToWorld(Vector(min.x,min.y,max.z)):ToScreen(),
        ent:LocalToWorld(Vector(min.x,max.y,min.z)):ToScreen(),
        ent:LocalToWorld(Vector(min.x,max.y,max.z)):ToScreen(),
        ent:LocalToWorld(Vector(max.x,min.y,min.z)):ToScreen(),
        ent:LocalToWorld(Vector(max.x,min.y,max.z)):ToScreen(),
        ent:LocalToWorld(Vector(max.x,max.y,min.z)):ToScreen(),
        ent:LocalToWorld(Vector(max.x,max.y,max.z)):ToScreen()
    }

    return corners
end

function GetCorners(corners)
    local minx, miny, maxx, maxy = ScrW() * 2, ScrH() * 2, 0, 0

    for _, corner in ipairs(corners) do
        minx,miny = math.min(minx, corner.x), math.min(miny, corner.y)
        maxx,maxy = math.max(maxx, corner.x), math.max(maxy, corner.y)
    end

    return {minx,miny,maxx,maxy}
end
net.Receive("gs_eq_med_glasses_sensors", function()
    local amnt = net.ReadUInt(4)

    MED_GLASS_ARRAY = {} 
    if amnt == 0 then return end
    for i = 1, amnt do 
        local ent = net.ReadEntity()
        local dmg  = net.ReadInt(11)

        local hp = math.Clamp(((dmg - 100) * -1), -100, 100)
        
        MED_GLASS_ARRAY[i] = {coords = GetCoordinates(ent)  , hp = hp}
    end

end)

hook.Add("PostDrawHUD", "GlassDrawHUD", function()
    -- if we have googles and googles have DrawHUD, then call him
    if !GS_ClPlyStat.init then return end
    if !GS_ClPlyStat:HaveEquip("EYES") then return end

    local glasses = GS_ClPlyStat:GetEquipClass("EYES")

    if !glasses then return end

    local dl = GS_FastDataLabels[glasses]

    if !dl then return end

    hook.Run("GS_Equip_DrawHUD", dl.type, dl.id)
    
end)