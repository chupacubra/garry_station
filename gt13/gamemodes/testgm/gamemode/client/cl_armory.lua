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


CL_ARMORY_PART = {
    head   = "HEAD",
    body   = "VEST",
}

local PLY = FindMetaTable("Player")

function PLY:DoImpactEffect(t, damageType)
    local part = HitGroupPart[t.HitGroup]
    local eq = CL_ARMORY_PART[part]


    if eq then
        local equip_model = player_manager.RunClass(self, "GetEquipModel", eq)
    
        if equip_model and equip_model != "" then
            local ar = cl_equip_config[equip_model]["armor"]
            if ar == AR_VEST then
                local efct = EffectData()
                efct:SetEntity(t.Entity)
                efct:SetOrigin(t.HitPos)
                efct:SetStart(t.StartPos)
                efct:SetSurfaceProp(table.Random(SP_SOFT))
                efct:SetDamageType(damageType)
                efct:SetHitBox(t.HitBox)
            
                util.Effect("Impact", efct)
                return
            elseif ar == AR_MET then
                local efct = EffectData()
                efct:SetOrigin(t.HitPos)
                efct:SetNormal(t.Normal)

                util.Effect("MetalSpark", efct)
                self:EmitSound(ArmoryMetallicImpact[math.random(1,#ArmoryMetallicImpact)])
                return
            end
        end
    end

    local efct = EffectData()
    efct:SetEntity(t.Entity)
    efct:SetOrigin(t.HitPos)
    efct:SetStart(t.StartPos)
    efct:SetSurfaceProp(t.SurfaceProps)
    efct:SetDamageType(damageType)
    efct:SetHitBox(t.HitBox)

    util.Effect("Impact", efct)
end

concommand.Add("makeimp", function(ply)
    local bonepos = ply:GetBonePosition( 6 )
    local startpos = bonepos + Vector(math.random(-30, 30), math.random(-30, 30), math.random(-30, 30))
    print(startpos, bonepos, ply:GetPos())

    debugoverlay.Line(startpos , bonepos, 10)

    local trace = {
        start = startpos,
        endpos = bonepos
    }

    ply:DoImpactEffect(util.TraceLine(trace), DMG_BULLET)
end)

