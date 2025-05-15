// this file handle drawing world models item in hands
// this for hands with items and SWEP

function PlayerHandsModelClear(ply)
    for i = 1, #ply.HandItemModels do
        ply.HandItemModels[i]:Remove()
        ply.HandItemModels[i] = nil
    end
end

function PlayerUpdateWorldModelsSWEP(ply, weps, active)
    //if !ply:IsActive() then return end
    if !ply.HandItemModels then
        ply.HandItemModels = {}
    else
        PlayerHandsModelClear(ply)
    end

    for i = 1, #weps <= 2 and #weps or 2 do
        local wep = weps[i]
        local isActive = active == wep
        local itm;
        if wep.IsHands then
            itm = wep:GetItem()
            if !IsValid(itm) then 
                continue
            end
        elseif isActive then continue end // because we dont create weapon model, if weapon is active
        print(wep, isActive, wep )
        local model = ClientsideModel(itm:GetModel())
        model:SetColor(itm:GetColor())
        
        local boneid = ply:LookupBone(  Either(isActive, "ValveBiped.Bip01_R_Hand" , "ValveBiped.Bip01_L_Hand" ))
        if !boneid then continue end
        
        local matrix = ply:GetBoneMatrix(boneid)
        if !matrix then continue end

        local offsetVec = model.HandOffsetVec or Vector(0,0,0)
        local offsetAng = model.HandOffsetAng or Angle(0, 0, 0)

        local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

        model:SetPos(newPos)
        model:SetAngles(newAng)
        model:FollowBone(ply, boneid)

        table.insert(ply.HandItemModels, model)
    end
end

hook.Add("PlayerSwitchWeapon", "UpdateDrawWeapon", function( ply, oldWeapon, newWeapon)
    PlayerUpdateWorldModelsSWEP(ply, ply:GetWeapons(), newWeapon)
end)