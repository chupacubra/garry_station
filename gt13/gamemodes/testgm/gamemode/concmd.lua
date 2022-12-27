concommand.Add( "gs_spawn", function( ply, cmd, args, str )
    GS_EntityControler:MakeEntity(0,0,ply:GetPos()+Vector(50,0,50),0)
 end )

concommand.Add( "gs_ammo", function( ply, cmd, args, str )
    GS_EntityControler:MakeAmmoBox("pistol",0,ply:GetPos()+Vector(50,0,50),0)
end )

concommand.Add( "gs_ttt", function( ply, cmd, args, str )
    --GS_EntityControler:MakeAmmoBox("pistol",0,ply:GetPos()+Vector(50,0,50),0)
end )

concommand.Add( "gs_magazine", function( ply, cmd, args, str )
    GS_EntityControler:MakeAmmoBox("pistol_magazine",0,ply:GetPos()+Vector(50,0,50),0)
end )

concommand.Add( "gs_pistol", function( ply, cmd, args, str )
    --GS_EntityControler:MakeEntity(0,0,ply:GetPos()+Vector(50,0,50),0)
    local ent = ents.Create("gs_weapon_pistol")
    ent:SetPos(ply:GetPos()+Vector(50,0,50))
    ent:Spawn()
end )


concommand.Add( "gs_backpack", function( ply, cmd, args, str )
    local ent = ents.Create("gs_simple_backpack")
    ent:SetPos(ply:GetPos()+Vector(50,0,50))
    ent:Spawn()
end )