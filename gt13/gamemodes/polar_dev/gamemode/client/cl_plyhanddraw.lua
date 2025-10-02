// this file handle drawing world models item in hands
// this for hands with items and SWEP

function PlayerHandsModelClear(ply)

    local hand_items = ply.HandItemModels

    for k, v in pairs(hand_items) do
        if !v.item:IsWeapon() then
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
    if !ply:IsActive() then return end
    if !ply:IsValid() then return end
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

/*
hook.Add("Think", "UpdateHandsDraw", function()
    // get old and new player sweps, check if is not ravno
    // пример кода
    // проблема только в одном - это надо делать для всех игроков
    // может в корутину?
    // или все таки сделать по нормальному
    if true return end

    local old = ply.Old
    local new = ply:GetWeapons()
    if old != new then

        PlayerUpdateWorldModelsSWEP
    end
end)
*/

hook.Add("Think", "UpdateHandsDraw", function()
    /*local old = ply.Old
    local new = ply:GetWeapons()
    if old != new then

        PlayerUpdateWorldModelsSWEP
    end*/
    for _, ply in ipairs(player.GetAll()) do
        //local new_weaps = ply:GetWeapons()
        //local f_equal = false
        /*
        for i = 1, #new do
            if new_weaps[i] != 
        end
        */
        //ply.OldWeapForCheck = new
        PlayerUpdateWorldModelsSWEP(ply)
    end
end)



hook.Add("PlayerSwitchWeapon", "UpdateDrawWeapon", function( ply, oldWeapon, newWeapon)
    timer.Simple(0, function()
        PlayerUpdateWorldModelsSWEP(ply)
    end)
end)

net.Receive("gs_hands_model_update", function()
    local ply = net.ReadPlayer()
    local ent = net.ReadEntity()

    print("update model hands cs", ply, ent)

    PlayerUpdateWorldModelsSWEP(ply)
end)