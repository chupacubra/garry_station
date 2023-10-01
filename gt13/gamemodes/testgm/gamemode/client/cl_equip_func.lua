net.Receive("gs_eq_med_glasses_sensors", function()
    local amnt = net.ReadUInt(4)
    --print(amnt, 22424)
    MED_GLASS_ARRAY = {}
    if amnt == 0 then return end
    for i = 1, amnt do 
        local ent = net.ReadEntity()
        local dmg  = net.ReadInt(11)

        local hp = math.Clamp(((dmg - 100) * -1), -100, 100)
        
        MED_GLASS_ARRAY[i] = {pos = ent:GetPos() + Vector(0, 0, 50), hp = hp}
    end

    --PrintTable(MED_GLASS_ARRAY)
end)

hook.Add("PostDrawHUD", "GlassDrawHUD", function()
    -- if we have googles and googles have DrawHUD, then call him
    --print("sdsd")
    if !GS_ClPlyStat.init then return end
    if !GS_ClPlyStat:HaveEquip("EYES") then return end

    local glasses = GS_ClPlyStat:GetEquipItem("EYES").ENT_Name
    --print(glasses)
    if !glasses then return end

    if GS_EntityList["goggles"][glasses]["CL_EQ_Func"] then
        GS_EntityList["goggles"][glasses]["CL_EQ_Func"]["DrawHUD"]()
    end

end)