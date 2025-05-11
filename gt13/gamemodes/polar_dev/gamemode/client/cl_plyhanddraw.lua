// this file handle drawing world models item in hands
// this for hands with items and SWEP

function PlayerHandsModelClear(ply)
    for i = 1, #ply.HandItemModels do
        ply.HandItemModels[i]:Remove()
        ply.HandItemModels[i] = nil
    end
end

function PlayerUpdateWorldModelsSWEP(ply, weps, active)
    if !ply:IsActive() then return end
    if !ply.HandItemModels then
        ply.HandItemModels = {}
    else
        PlayerHandsModelClear(ply)
    end

    for i = 1, #weps <= 2 and #weps or 2 do
        local itm = weps[i]
        local isActive = active == itm
        
        if itm.IsHands then
            itm = wep:GetItem()
            if !itm then continue end
        elseif isActive then continue end // because we dont create weapon model, if weapon is active

        local model = ClientsideModel(wep:GetModel())
        model:SetColor(wep:GetColor())
        
        local boneid = ply:LookupBone( "ValveBiped.Bip01_R_Hand" and isActive or "ValveBiped.Bip01_L_Hand" )
        if !boneid then continue end
        
        local matrix = owner:GetBoneMatrix(boneid)
        if !matrix then continue end

        local offsetVec = model.HandOffsetVec or Vector(3, -3, -1)
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