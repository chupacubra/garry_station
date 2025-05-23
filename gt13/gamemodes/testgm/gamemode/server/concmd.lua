--[[
concommand.Add( "gs_spawn", function( ply, cmd, args, str )
    GS_EntityControler:MakeEntity(0,0,ply:GetPos()+Vector(50,0,50),0)
 end )

concommand.Add( "gs_box", function( ply, cmd, args, str )
    GS_EntityControler:MakeEntity2("cardboard_box","ent_container",ply:GetPos()+Vector(50,0,50),0)
end )

concommand.Add( "gs_sbox", function( ply, cmd, args, str )
    GS_EntityControler:MakeEntity2("cardboard_box","ent_container_small",ply:GetPos()+Vector(50,0,50),0)
end )

concommand.Add( "gs_bucket", function( ply, cmd, args, str )
    GS_EntityControler:MakeEntity2("bucket","ent_chem_container_small",ply:GetPos()+Vector(50,0,50),0)
end )

concommand.Add( "gs_fridge", function( ply, cmd, args, str )
    GS_EntityControler:MakeEntity2("fridge","ent_container",ply:GetPos()+Vector(50,0,50),0)
end )

concommand.Add( "gs_ammo", function( ply, cmd, args, str )
    GS_EntityControler:MakeAmmoBox("pistol",0,ply:GetPos()+Vector(50,0,50),0)
end )

concommand.Add( "gs_ttt", function( ply, cmd, args, str )
    --GS_EntityControler:MakeAmmoBox("pistol",0,ply:GetPos()+Vector(50,0,50),0)
end )

concommand.Add( "gs_magazine", function( ply, cmd, args, str )
    GS_EntityControler:MakeAmmoBox("tekov_magazine",0,ply:GetPos()+Vector(50,0,50),0)
end)

concommand.Add( "gs_mag", function( ply, cmd, args, str )
    --GS_EntityControler:MakeAmmoBox("tekov_magazine",0,ply:GetPos()+Vector(50,0,50),0)
    GS_EntityControler:CreateFullMagazine("tekov_magazine", AMMO_9MM ,ply:GetPos()+Vector(50,0,50),0)
end)

concommand.Add( "gs_smag", function( ply, cmd, args, str )
    --GS_EntityControler:MakeAmmoBox("tekov_magazine",0,ply:GetPos()+Vector(50,0,50),0)
    GS_EntityControler:CreateFullMagazine("hn40_magazine", AMMO_9MM ,ply:GetPos()+Vector(50,0,50),0)
end)

concommand.Add( "gs_shotgun", function( ply, cmd, args, str )
    --GS_EntityControler:MakeEntity(0,0,ply:GetPos()+Vector(50,0,50),0)
    local ent = ents.Create("gs_weapon_sg12")
    ent:SetPos(ply:GetPos()+Vector(50,0,50))
    ent:Spawn()
    --ent:TriggerLoadWorldModel(false)
end )

concommand.Add( "gs_pistol", function( ply, cmd, args, str )
    --GS_EntityControler:MakeEntity(0,0,ply:GetPos()+Vector(50,0,50),0)
    local ent = ents.Create("gs_weapon_pistol")
    ent:SetPos(ply:GetPos()+Vector(50,0,50))
    ent:Spawn()
    --ent:TriggerLoadWorldModel(false)
end )

concommand.Add( "gs_wrench", function( ply, cmd, args, str )
    local ent = ents.Create("gs_tool_wrench")
    ent:SetPos(ply:GetPos()+Vector(50,0,50))
    ent:Spawn()
end )

concommand.Add( "gs_machine", function( ply, cmd, args, str )
    local ent = ents.Create("gs_machine_casing")
    ent:SetPos(ply:GetPos()+Vector(50,0,50))
    ent:Spawn()
end )

concommand.Add( "gs_crowbar", function( ply, cmd, args, str )
    local ent = ents.Create("gs_tool_crowbar")
    ent:SetPos(ply:GetPos()+Vector(50,0,50))
    ent:Spawn()
end )

concommand.Add( "gs_scomp", function( ply, cmd, args, str )
    local ent = ents.Create("gs_computer")
    ent:SetPos(ply:GetPos()+Vector(50,0,50))
    ent:Spawn()
end )

concommand.Add( "gs_screw", function( ply, cmd, args, str )
    local ent = ents.Create("gs_tool_screwdriver")
    ent:SetPos(ply:GetPos()+Vector(50,0,50))
    ent:Spawn()
end )

concommand.Add( "gs_smg", function( ply, cmd, args, str )
    --GS_EntityControler:MakeEntity(0,0,ply:GetPos()+Vector(50,0,50),0)
    local ent = ents.Create("gs_weapon_hn40")
    ent:SetPos(ply:GetPos()+Vector(50,0,50))
    ent:Spawn()
    --ent:TriggerLoadWorldModel(false)
end )


concommand.Add( "gs_pile", function( ply, cmd, args, str )
    GS_EntityControler:MakeAmmoBox("pile_9mm",0,ply:GetPos()+Vector(50,0,50),0)
end )

concommand.Add( "gs_dmgself", function( ply, cmd, args, str )
    player_manager.RunClass( ply,"HurtPart", 7, {[D_BRUTE] = 10,[D_STAMINA] = 10,})
end )

concommand.Add( "gs_respawn", function( ply, cmd, args, str )
    -- kill ply
    -- remove ply from dead table
    -- respawn with equip

    --player_manager.RunClass( ply,"HurtPart", 7, {[D_BRUTE] = 10,[D_STAMINA] = 10,})
    if ply:Alive() then

    end
end )

concommand.Add( "gs_rag", function( ply, cmd, args, str )
    player_manager.RunClass( ply,"Ragdollize")
end )

concommand.Add( "gs_water", function( ply, cmd, args, str )
    player_manager.RunClass( ply,"InjectChemical","water",10)
end )
concommand.Add( "gs_leaf", function( ply, cmd, args, str )
    player_manager.RunClass( ply,"InjectChemical","water",10)
end )

concommand.Add( "gs_examine", function( ply, cmd, args, str )
    print(ply:Examine(ply))
end )


concommand.Add( "gs_spawn", function( ply, cmd, args, str )
    PrintTable(args)
    print(cmd)
    --player_manager.RunClass( ply,"InjectChemical","water",10)
    GS_EntityControler:MakeEntity(args[1],args[2],ply:GetPos()+Vector(50,0,50),0)
end )

concommand.Add( "gs_task", function( ply, cmd, args, str )
    GS_Task:CreateNew(ply,"test_task", 5, game.GetWorld(),{
        start  = function(ply,_)
            ply:ChatPrint("You start screwing the machine casing")
        end,
        succes = function(ply,_)
            ply:ChatPrint("You screwed machine case")
        end,
        unsucces = function(ply,_)
            ply:ChatPrint("You stop screwing machine case")
        end
    },{},"Screwdriving some...")
end )



concommand.Add( "gs_craft", function( ply, cmd, args, str )
    GS_Craft:CraftEntity(ply)
end )
--GS_Craft:CraftEntity
--]]

concommand.Add( "gs_force_spawn", function( ply, cmd, args, str )
    ply:SetTeam(TEAM_PLY)
    ply:SetModel("models/player/phoenix.mdl")
    ply:Spawn()
end )