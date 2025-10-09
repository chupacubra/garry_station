// this file handle drawing world models item in hands
// this for hands with items and SWEP

function PlayerHandsModelClear(ply)
    print("clearing cl models")
    local hand_items = ply.HandItemModels

    for k, v in pairs(hand_items) do
        if !v.item:IsWeapon() or !v.item.WorldModelCustom then
            v.model:Remove()
            v = nil
        else
            v = nil
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


local function UpdateWorldModels(ply, new)
    PlayerHandsModelClear(ply)

    for k, v in pairs(new) do
        if !v.model then
            local item = v.item
            model = ClientsideModel(item:GetModel())
            model:SetColor(item:GetColor())
            model:SetSkin(item:GetSkin())
            
            if ply != LocalPlayer() then
                model:SetNoDraw(true)
            end
            
            CopyBodyGroups(v.item, model)
            v.model = model
        end
    end
end

function PlayerUpdateWorldModelsSWEP1(ply)
    local sweps = ply:GetWeapons()
    local active = ply:GetActiveWeapon()

    local old_HandItemModels = ply.HandItemModels or {}

    local new_HandItemModels = {}

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
            if isActive then
                continue
            end
        end 

        
        local model = item:GetModel()

        table.insert(new_HandItemModels, {
            model = item.WMGun or swep.WMGun,
            //cl_model = item.WMGun or swep.WMGun,
            isActive = isActive,
            offsetVec = item.HandOffsetVec or Vector(),
            offsetAng = item.HandOffsetAng or Angle(),
            item = item,
            isSWEP = !swep.IsHands,
        })
    end
    
    if #old_HandItemModels != #new_HandItemModels then
        print("NE SHODSTVO")
        UpdateWorldModels(ply, new_HandItemModels)

        ply.HandItemModels = new_HandItemModels
        return
    end

    for k, v in pairs(old_HandItemModels) do
        v.isActive = new_HandItemModels[k].isActive
        //print(v.ent_item, new_HandItemModels[k].ent_item )
        if v.ent_item == new_HandItemModels[k].ent_item then
            // обновление бодигруп?
            
            continue
        else
            //updateHandsModels
            print("NE SHODSTVO")
            UpdateWorldModels(ply, new_HandItemModels)

            ply.HandItemModels = new_HandItemModels
            break
        end
    end
end

function PlayerUpdateWorldModelsSWEP(ply)
    local sweps = ply:GetWeapons()
    local active = ply:GetActiveWeapon()

    // каждый раз удалять модели это не хорошо, поэтому немного дергано выглядит

    local old_HandItemModels = table.Copy

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
        //print(IsValid(item.WMGun) and item.GSWEP == true)
        if IsValid(swep.WMGun)then
            model = swep.WMGun
        elseif IsValid(item.WMGun) then
            model = item.WMGun
        else
            //print("123")
            model = ClientsideModel(item:GetModel())
            model:SetColor(item:GetColor())
            model:SetSkin(item:GetSkin())
            
            if ply != LocalPlayer() then
                model:SetNoDraw(true)
            end
            
            CopyBodyGroups(item, model)
        end

        local offsetVec, offsetAng
        
        offsetVec = item.HandOffsetVec or Vector()
        offsetAng = item.HandOffsetAng or Angle()

        table.insert(ply.HandItemModels, {
            model = model,
            isActive = isActive,
            offsetVec = offsetVec,
            offsetAng = offsetAng,
            item = item,
        })
    end

end




hook.Add( "PostPlayerDraw" , "Draw Hands models", function( ply )
    //if ply == LocalPlayer() then return end
    if !ply:IsValid() then return end
    if !ply:IsActive() then return end
    local hand_items = ply.HandItemModels 
    if !hand_items then return end

    for _, mdlData in ipairs(hand_items) do
        local mdl       = mdlData.model
        local active    = mdlData.isActive
        local pos_offset = mdlData.offsetVec
        local ang_offset = mdlData.offsetAng

        local boneid = ply:LookupBone( Either(active, "ValveBiped.Bip01_R_Hand" , "ValveBiped.Bip01_L_Hand" ) )
            
        if not boneid then
            continue
        end

        local matrix = ply:GetBoneMatrix( boneid )
        
        if not matrix then 
            continue
        end

        local pos, ang = matrix:GetTranslation(), matrix:GetAngles()

        local Right, Forward, Up = ang:Right(), ang:Forward(), ang:Up()
        pos = pos + Right * pos_offset.x + Forward * pos_offset.y + Up * pos_offset.z

        ang:RotateAroundAxis(Right, ang_offset.p)
        ang:RotateAroundAxis(Up,ang_offset.y)
        ang:RotateAroundAxis(Forward, ang_offset.r)


        mdl:SetupBones()
        mdl:DrawModel()
        mdl:SetRenderOrigin(pos)
        mdl:SetRenderAngles(ang)
        //print(mdl)

        // next we render chem cont with rendering liquid
        if mdlData.item.IsChemContainer then continue end
        if !IsValid(mdlData.item.RenderChem_Mesh) then continue end

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

hook.Add("Think", "UpdateHandsDraw", function()
    for _, ply in ipairs(player.GetAll()) do
        PlayerUpdateWorldModelsSWEP1(ply)
    end
end)



hook.Add("PlayerSwitchWeapon", "UpdateDrawWeapon", function( ply, oldWeapon, newWeapon)
    timer.Simple(0, function()
        PlayerUpdateWorldModelsSWEP1(ply)
    end)
end)

net.Receive("gs_hands_model_update", function()
    local ply = net.ReadPlayer()
    local ent = net.ReadEntity()

    print("update model hands cs", ply, ent)

    PlayerUpdateWorldModelsSWEP1(ply)
end)