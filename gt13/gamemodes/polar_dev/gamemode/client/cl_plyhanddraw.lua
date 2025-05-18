// this file handle drawing world models item in hands
// this for hands with items and SWEP

function PlayerHandsModelClear(ply)
    for i = 1, #ply.HandItemModels do
        ply.HandItemModels[i]:Remove()
        ply.HandItemModels[i] = nil
    end
end

function PlayerUpdateWorldModelsSWEP(ply, sweps, active, drawEnt)
    //if !ply:IsActive() then return end
    if !ply.HandItemModels then
        ply.HandItemModels = {}
    else
        PlayerHandsModelClear(ply)
    end

    for i = 1, #sweps <= 2 and #sweps or 2 do
        local swep = sweps[i]
        local isActive = active == swep
        local item

        if swep.IsHands then
            if IsValid(drawEnt) and isActive then -- nv cant fast update vals, then we force sending pickuped ents  
                item = drawEnt
            else
                item = swep:GetItem()
                
                if !IsValid(item) then 
                    continue
                end
            end
        elseif isActive then continue end 
        --[[
        if item.WorldModelCustom then
            if item.
        end
        --]]
        local model = ClientsideModel(item:GetModel())
        model:SetColor(item:GetColor())
        
        local boneid = ply:LookupBone(  Either(isActive, "ValveBiped.Bip01_R_Hand" , "ValveBiped.Bip01_L_Hand" ))
        if !boneid then continue end
        
        local offsetVec = model.HandOffsetVec or Vector(3, 0, 0)
        local offsetAng = model.HandOffsetAng or Angle(90, 0, 90)

        //local newPos, newAng = ply:GetBonePosition( boneid )
        //debugoverlay.Cross(newPos, 10, 5, nil, true)
        
        model:FollowBone(ply, boneid)
        model:SetAngles(ply:GetAngles()+ offsetAng)
        model:SetPos(ply:LocalToWorld(offsetVec))

        table.insert(ply.HandItemModels, model)
    end
end

hook.Add("PlayerSwitchWeapon", "UpdateDrawWeapon", function( ply, oldWeapon, newWeapon)
    PlayerUpdateWorldModelsSWEP(ply, ply:GetWeapons(), newWeapon)
end)

net.Receive("gs_hands_model_update", function()
    local ply = net.ReadPlayer()
    local ent = net.ReadEntity()

    PlayerUpdateWorldModelsSWEP(ply, ply:GetWeapons(), ply:GetActiveWeapon(), ent)
end)