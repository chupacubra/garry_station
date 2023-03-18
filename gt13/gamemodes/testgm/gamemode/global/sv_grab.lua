local PlayerGrabEntity = {}

function GrabEntity(ply,ent)
    --[[
        check CAN we pickup these prop (it is a gs_entity)
        for grabbing corpses need other functions
    ]]

    --[[
    if !ent:OnGround() then
        return
    end
    --]]

    if ent.GrabData then
        UngrabEntity(ent)
        return
    end
    
    local grab = {} 

    grab.GrabPlayer = ply
    grab.GrabPos    = ply:WorldToLocal(ent:GetPos())
    grab.GrabMat    = ent:GetPhysicsObject():GetMaterial()

    ent.GrabData = grab

    player_manager.RunClass( ply, "EffectSpeedAdd", "grab_entity", -150, -350 )
    construct.SetPhysProp( ent:GetOwner(), ent, 0, nil, { GravityToggle = true, Material = "slipperyslime" } )
    
    GS_ChatPrint(ply, "You grab the "..ent.Entity_Data.Name)

    hook.Add("Think", "GS_GrabEntity-"..ent:EntIndex(), function()
        if !IsValid(ent.GrabData.GrabPlayer) then
            UngrabEntity(ent)
            return
        end

        local dist = ent:GetPos():Distance( ent.GrabData.GrabPlayer:LocalToWorld(ent.GrabData.GrabPos))
        if dist > 100 then
            UngrabEntity(ent)
            return
        end

        if dist > 10 then
            local pos = ent.GrabData.GrabPlayer:LocalToWorld(ent.GrabData.GrabPos)
            local phys = ent:GetPhysicsObject()

            local cpos = pos - ent:GetPos()

            cpos:Normalize()

            local force = cpos * dist

            phys:SetVelocity(force)            
        end
    end)
end

function UngrabEntity(ent)
    if ent.GrabData.GrabPlayer then
        player_manager.RunClass( ent.GrabData.GrabPlayer, "EffectSpeedRemove", "grab_entity")
        GS_ChatPrint(ent.GrabData.GrabPlayer, "You stop grabbing "..ent.Entity_Data.Name)
    end

    construct.SetPhysProp( ent:GetOwner(), ent, 0, nil, { GravityToggle = true, Material = ent.GrabData.GrabMat } )
    hook.Remove("Think", "GS_GrabEntity-"..ent:EntIndex())
    ent.GrabData = nil
end

net.Receive("gs_ent_grab", function(_,ply)
    local ent = net.ReadEntity()
    print(112414)
    GrabEntity(ply, ent)
end)