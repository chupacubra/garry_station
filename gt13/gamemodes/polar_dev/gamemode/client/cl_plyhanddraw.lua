// this file handle drawing world models item in hands
// this for hands with items and SWEP

function PlayerHandsModelClear(ply)
    for i = 1, #ply.HandItemModels do
        print(ply.HandItemModels[i].item, ply.HandItemModels[i].item:IsWeapon() )
        if !ply.HandItemModels[i].item:IsWeapon() then
            ply.HandItemModels[i].model:Remove()
            ply.HandItemModels[i] = nil
        else
            ply.HandItemModels[i] = nil
        end
    end
    ply.HandItemModels = {}
end

local function CopyBodyGroups(from, to)
    if from:GetModel() != to:GetModel() then return end
    for id = 0, from:GetNumBodyGroups() - 1 do
        if id then
            to:SetBodygroup(id, from:GetBodygroup(id))
        end
    end
end

function PlayerUpdateWorldModelsSWEP(ply)
    /*
    local sweps = ply:GetWeapons()
    local active = ply:GetActiveWeapon()

    if !ply.HandItemModels then
        ply.HandItemModels = {}
    else
        PlayerHandsModelClear(ply)
    end

    for i = 1, #sweps <= 2 and #sweps or 2 do
        local swep = sweps[i]
        local isActive = active == swep
        local item = swep
        local haveModel = IsValid(swep.WMGun)

        if swep.IsHands then
            item = swep:GetItem()
            
            if !IsValid(item) then 
                continue
            end
        
        elseif isActive then
            continue
        end 

        local model
        if item.WMGun then
            //continue
            model = item.WMGun
            //model:SetNoDraw(false)
        else
            model = ClientsideModel(item:GetModel())
            model:SetColor(item:GetColor())
            model:SetSkin(item:GetSkin())
            CopyBodyGroups(item, model)
        end

        local offsetVec, offsetAng
        
        offsetVec = item.HandOffsetVec or Vector(3, 0, 0)
        offsetAng = item.HandOffsetAng or Angle(90, 0, 90)

        
        if item:IsWeapon() and item.WorldModelOffsets then
            offsetVec = item.WorldModelOffsets.pos or offsetVec
            offsetAng = item.WorldModelOffsets.ang or offsetAng
            //print("123213s")
        end

        table.insert(ply.HandItemModels, {
            model = model,
            isActive = isActive,
            offsetVec = offsetVec,
            offsetAng = offsetAng,
            item = item,
        })

        print("hands models")
        PrintTable(ply.HandItemModels)
        
    end
    

    //local sweps = ply:GetWeapons()
    //local active = ply:GetActiveWeapon()

//    if !ply.HandItemModels then
//        ply.HandItemModels = {}
    */
end

function PlayerUpdateWorldModelsSWEP(ply)
    local sweps = ply:GetWeapons()
    local active = ply:GetActiveWeapon()

    if !ply.HandItemModels then
        ply.HandItemModels = {}
    else
        PlayerHandsModelClear(ply)
    end

    for i = 1, #sweps <= 2 and #sweps or 2 do
        local swep = sweps[i]
        local isActive = active == swep
        local item = swep
        local haveModel = IsValid(swep.WMGun)

        if swep.IsHands then
            item = swep:GetItem()
            
            if !IsValid(item) then 
                continue
            end
        
        else
            //print(swep, isActive)
            if isActive then
                // dont create model, use swep model
                continue
            end
        end 

        local model
        if IsValid(swep.WMGun) and swep.GMSWEP then
            //continue
            print("use swep mdl")
            model = swep.WMGun
            //model:SetNoDraw(false)
        else
            model = ClientsideModel(item:GetModel())
            model:SetColor(item:GetColor())
            model:SetSkin(item:GetSkin())
            CopyBodyGroups(item, model)
        end

        local offsetVec, offsetAng
        
        offsetVec = item.HandOffsetVec or Vector(0 ,0, 0)
        offsetAng = item.HandOffsetAng or Angle(0, 0, 0)

        table.insert(ply.HandItemModels, {
            model = model,
            isActive = isActive,
            offsetVec = offsetVec,
            offsetAng = offsetAng,
            item = item,
        })

        //print("hands models")
        //PrintTable(ply.HandItemModels)
        
    end

end


hook.Add( "PostPlayerDraw" , "Draw Hands models", function( ply )
    if !ply:IsValid() then return end
    if !ply.HandItemModels then return end

    for i = 1, 2 do
        local mdlData = ply.HandItemModels[i]
        
        if !mdlData then continue end
        
        local mdl       = mdlData.model
        local active    = mdlData.isActive
        local pos_offset = mdlData.offsetVec
        local ang_offset = mdlData.offsetAng

        local boneid = ply:LookupBone( Either(active, "ValveBiped.Bip01_R_Hand" , "ValveBiped.Bip01_L_Hand" ) )
            
        if not boneid then
            return
        end
        
        local matrix = ply:GetBoneMatrix( boneid )
        
        if not matrix then 
            return 
        end

        local pos, ang = matrix:GetTranslation(), matrix:GetAngles()

        local Right, Forward, Up = ang:Right(), ang:Forward(), ang:Up()
        pos = pos + Right * pos_offset.x + Forward * pos_offset.y + Up * pos_offset.z

        ang:RotateAroundAxis(Right, ang_offset.p)
        ang:RotateAroundAxis(Up,ang_offset.y)
        ang:RotateAroundAxis(Forward, ang_offset.r)

        mdl:SetRenderOrigin(pos)
        mdl:SetRenderAngles(ang)
        mdl:SetupBones()
        mdl:DrawModel()

        // next we render chem cont with rendering liquid
        
        if mdlData.item.IsChemContainer then return end
        if !IsValid(mdlData.item.RenderChem_Mesh) then return end

        local item = mdlData.item

        local msh = item.RenderChem_Mesh
        local size = item.RenderChem_Size
        local height = item.RenderChem_Height

        local m = Matrix()
        m:SetTranslation(item:LocalToWorld(height))
        m:SetScale(item.RenderChem_Size)
        m:Rotate(item:GetAngles())

        cam.PushModelMatrix( m, true )
            msh:Draw()
        cam.PopModelMatrix()
    end

end)


hook.Add("PlayerSwitchWeapon", "UpdateDrawWeapon", function( ply, oldWeapon, newWeapon)
    timer.Simple(0, function() PlayerUpdateWorldModelsSWEP(ply) end)
    //PlayerUpdateWorldModelsSWEP(ply)
end)

net.Receive("gs_hands_model_update", function()
    local ply = net.ReadPlayer()
    local ent = net.ReadEntity()

    print("update model hands cs", ply, ent)

    PlayerUpdateWorldModelsSWEP(ply)
end)