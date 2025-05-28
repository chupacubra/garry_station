concommand.Add( "gs_force_spawn", function( ply, cmd, args, str )
    ply:SetTeam(TEAM_PLY)
    ply:SetModel("models/player/phoenix.mdl")
    ply:Spawn()
end )


function PrintBones( entity )
    for i = 0, entity:GetBoneCount() - 1 do
        print( i, entity:GetBoneName( i ) )
    end
end

concommand.Add("getbg", function()
    local prop = ents.Create("prop_physics")
    prop:SetModel(mdl)
    prop:Spawn()
    
    PrintTable(prop:GetBodyGroups())
    PrintTable(prop:GetAttachments())
    
    PrintBones(prop)

    prop:Remove()
end)

