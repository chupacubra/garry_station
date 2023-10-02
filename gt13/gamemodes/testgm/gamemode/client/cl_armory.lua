-- здесь кароче будут некоторые приколы с броней для клиентов
-- по типу рисования эффекта металических искр или при попадания в каску или бронежилет
-- для того, чтобы эффект попадания был настроен (Impact), нужно записать флаги SurfaceProp
-- посути, будут два эффекта: 
--    маленький серый дым  -- для броников 
--    металические искры   -- для касок

-- soft 9, 47,  48
-- metalic 3, 66, 72, 7

SP_SOFT = {9,47, 48}
SP_METL = {3,7,66,72}

--[[
ArmorySoftImpact = {
    "physics/cardboard/cardboard_box_impact_bullet1.wav",
    "physics/cardboard/cardboard_box_impact_bullet2.wav",
    "physics/cardboard/cardboard_box_impact_bullet3.wav",
    "physics/cardboard/cardboard_box_impact_bullet4.wav",
    "physics/cardboard/cardboard_box_impact_bullet5.wav"
}

ArmoryMetallicImpact = {
    "physics/metal/metal_box_impact_bullet1.wav",
    "physics/metal/metal_box_impact_bullet2.wav",
    "physics/metal/metal_box_impact_bullet3.wav",
}
--]]
local PLY = FindMetaTable("Player")

function PLY:DoImpactEffect(t, damageType)
    local part = HitGroupPart[tr.HitGroup]
    
    local equip_model = player_manager.RunClass(self, "GetEquipModel", part)
    
    local sp = self:GetSurfaceProp()

    if equip_model then
        local ar = cl_equip_config[equip_model]["armor"]
        if ar == AR_VEST then
            sp = table.Random(SF_SOFT)
        elseif ar == AR_MET then
            sp = table.Random(SF_METL)
        end
    end

    local efct = EffectData()
    efct:SetEntity(t.Entity)
    efct:SetOrigin(t.HitPos)
    efct:SetStart(t.StartPos)
    efct:SetSurfaceProp(sp)
    efct:SetDamageType(damageType)
    efct:SetHitBox(t.HitBox)

    util.Effect("Impact", efct)
end