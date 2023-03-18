GS_Corpse = {}

--[[
    THE CORPSE MUST BE APART HUMAN
    SAVE IN CORPSE ONLY ID PLY
]]

function GS_Corpse.SendCorpseClient(rag)
    net.Start("gs_sys_corpse_create")
    net.WriteEntity(rag)
    net.Broadcast()
end

function GS_Corpse.Create(ply)
    local ragdoll = ents.Create("prop_ragdoll")

    ragdoll:SetCustomCollisionCheck(true)
    ragdoll:SetPos( ply:GetPos() )
    ragdoll:SetModel( ply:GetModel() )
    ragdoll:SetAngles(Angle((ply:GetAngles().p), (ply:GetAngles().y), ply:GetAngles().r))
    ragdoll:Spawn()

    ragdoll.RagdollStartSpeed = ply:GetVelocity()

    local bones = ragdoll:GetPhysicsObjectCount()
    for i=1,bones-1 do
        local bone = ragdoll:GetPhysicsObjectNum( i )  
        if bone:IsValid() then  

            local bonepos = ply:GetBonePosition( ragdoll:TranslatePhysBoneToBone( i ) ) 
            local bonematrix = ply:GetBoneMatrix(ragdoll:TranslatePhysBoneToBone( i ))
            local boneang = bonematrix:GetAngles()

            bone:SetPos( bonepos )  
            bone:SetAngles( boneang )  
            bone:SetVelocity(ragdoll.RagdollStartSpeed)  
        end  
    end

    ragdoll.ownerID = ply:SteamID()
    ragdoll.corpse  = true
    GS_Corpse.SendCorpseClient(ragdoll)

    return ragdoll
end


function GS_Corpse.SetRagdollDeath(ply,rag,leave) -- if ply death in crit paralyze -> set RAG to death
    --[[
        set equipment, pockets
        set hp (for redeem?!)
        set data
    
        if ply is DEAD ->
            all actions handler GS_Corpse
        else crit only
            all actions handler GS_Corpse AND gs_human CLASS
    ]]
    rag.ply_dead   = true
    rag.ownerID    = ply:SteamID()
    rag.disconnect = leave

    local equip     = ply.Equipment
    local pocket    = ply.Pocket
    local body      = ply.BODY
    local hp_effect = ply.HP_Effect
    --local
    rag.Corpse = {
        Equipment = equip,
        Pocket    = pocket,
        Body      = body,
        hp_eff    = hp_effect,
    }
end

function GS_Corpse.ExamineRag(viewer, rag)
    local examine = {}

    table.insert(examine, "It's human corpse.")
    --test: alive or ded

    if rag.ply_dead then
        if rag.disconnect then
            table.insert(examine, "Deep depression...")
        else
            table.insert(examine, "It's DEAD!")
        end 
    else
        --test: status hp
        local ply = player.GetBySteamID(rag.ownerID)

        if IsValid(ply) then
            local hp_stat = ply.HealthStatus
            if hp_stat == GS_HS_OK then
                table.insert(examine, "It's look good")
            elseif hp_stat == GS_HS_CRIT then
                table.insert(examine, "Face is pale...")
            end
        else
            --GS_MSG(rag.ownerID.." no in server but rag in not dead mark and this runned, WTF?")
            table.insert(examine, "The is strange")
        end
    end

    net.Start("gs_cl_inventary_examine_return")
	net.WriteTable(examine)
	net.Send(viewer)

end

net.Receive("gs_sys_corpse_action", function(_,ply)
    local rag = net.ReadEntity()
    local act = net.ReadUInt(4)
    local arg = net.ReadUInt(4)

    if !IsValid(rag) then
        return
    end

    if act == 0 then  -- EXAMINE COPRSE
        GS_Corpse.ExamineRag(ply, rag)
    else
        --[[
            other actions
        ]]
    end
end)