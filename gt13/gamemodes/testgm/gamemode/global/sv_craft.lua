GS_Craft = {}
GS_Craft.Receipts = {}


function GS_Craft:CraftEntity(ply, ent_name)
    if !IsValid(ply) then
        GS_MSG("Wtf, "..tostring(ply).." want to craft "..ent_name)
        return
    end

    --[[
        check around ply for ingridients and tools
        tools don't spend

        if tools == 1
            tool in hand
        elif tools > 1 
            1 tool need in hand, another in swep inventory OR on floor
        

        for searching all components
            1. look in hands
            2. look in floor
    ]]

    --check ingredients

    local pos = ply:GetPos()
    
    local v_max = pos:LocalToWorld(Vector(-50,-50,0))
    local v_min = pos:LocalToWorld(Vector(50,50,50))

    local all_components = {}
    local all_tools = {}

    for entity in pairs(ents.FindInBox( v_max, v_min )) do
        if entity.GS_Item and !entity.ItemBox then
        
        end
    end
    
end