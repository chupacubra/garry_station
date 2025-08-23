//
//
//

GameMap = {}
/*
    GameMap.Map = {
        spawnpoinst
        
    spawnpoints = {
        type
        pos
        job
    }
    keypads = {
        entid
        pos
        //ang
        access
    }
    entities = {
        // spawn entities or replace?
        entid
        
        pos
        ang


        class
        options {} // if want to replace name, desk ...

    }
    buttons = {
        // some buttons with castom functional
        entid

        access
        luacallback - string lua function
    }
*/


local props_to_replace = {
    // [".mdl"] = "cont_box"
}

function AddMapPropReplace(model, class)
    if props_to_replace[model] then
        GS_MSG("GameMap: entity "..tostring(class).. "already added to replace, rewrite", "w")
    end

    props_to_replace[model] = class
    GS_MSG("GameMap: replace "..tostring(model).." for "..tostring(class))
end

local function applyOptions(ent, data)
    //
    //
    //
end

function GameMap:GetConfig(map)
    //self.Map = map
    self.MapObjects = {}

    table.Merge(self.MapUseObjects, map.keypads)
    table.Merge(self.MapUseObjects, map.buttons)

    self.MapEntities = map.entities

    self.SpawnPoints = map.spawnpoints
end

function GameMap:PrepareToRound()
    //replace all entity maps to ours
    //spawn our entitys
    GS_MSG("GameMap: start preparing to round")
    GS_MSG("GameMap: replacing props to ents")

    for model, class in pairs(props_to_replace) do
        for _, prop in pairs(ents.FindByModel(model)) do
            local pos, ang = prop:GetPos(), prop:GetAngles()
            prop:Remove()

            local ent = ents.Create(class)
            if !ent then continue end
            ent:SetPos(pos)
            ent:SetAng(ang)
            ent:Spawn()
            
        end
    end
    
    GS_MSG("GameMap: all props replaced")
    GS_MSG("GameMap: spawn our ents")

    local spawn_ents = MapEntities

    for k, data in pairs(spawn_ents) do
        local pos, ang = data.pos, data.ang
        local class = data.ang

        local ent = ents.Create(class)
        if !ent then
            GS_MSG("GameMap: fail to spawn "..tostring(k).." ent, because class ("..tostring(class)..") is not valid!")
            continue
        end
        ent:SetPos(pos)
        ent:SetAng(ang)

        if data.options then
            applyOptions(ent, data.options)
        end

        ent:Spawn()
    end
    GS_MSG("GameMap: spawn our ents finish")

end



// basic type
// 
//  startround
//  and other
function GameMap:GetSpawnPoint(type, job)
end

function GameMap:UseMapObject(ply, ent, data)
    //if ply:IsActive()
    return
end

/*
hook.Add("PlayerUse", "UseMapObject", function(ply, ent)
    if !ent:CreatedByMap() then return end
    GameMap:UseMapObject(ply, ent)
end)
*/

hook.Add( "AcceptInput", "UseMapObject", function( ent, name, activator, caller, data )
    return GameMap:UseMapObject(activator, ent, data)
end)
