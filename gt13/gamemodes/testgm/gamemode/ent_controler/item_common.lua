GS_EntityList.parts = {
    plug = { 
        Entity_Data = {
            Name = "Electronic plug",
            Desc = "Part of big machines",
            Model = "models/props_lab/tpplug.mdl",
            ENT_Name = "part_plug",
            ENUM_Type = GS_ITEM_COMMON,
            Simple_Examine = true
        },
    }, 
    p_wheel = { 
        Entity_Data = {
            Name = "Mechanic wheel",
            Desc = "Part of big machines",
            Model = "models/props_c17/pulleywheels_small01.mdl",
            ENT_Name = "part_wheel",
            ENUM_Type = GS_ITEM_COMMON,
            Simple_Examine = true
        },
    },
    p_electronic = { 
        Entity_Data = {
            Name = "Electronics",
            Desc = "Part of big machines",
            Model = "models/props_lab/reciever01d.mdl",
            ENT_Name = "part_electronic",
            ENUM_Type = GS_ITEM_COMMON,
            Simple_Examine = true
        },
    }
}

GS_EntityList.Board_Parts_Fast = {}

for k,v in pairs(GS_EntityList.parts) do
    GS_EntityList.Board_Parts_Fast[v.Entity_Data.ENT_Name] = k
end

function GS_EntityList.GetPartNiceName(ent_name)
    --local ent = GS_EntityList.Board_Parts_Fast[ent_name]
    if GS_EntityList.Board_Parts_Fast[ent_name] then
        local key = GS_EntityList.Board_Parts_Fast[ent_name]
        return GS_EntityList.parts[key]["Entity_Data"]["Name"]
    end
    return false
end


--models/props_lab/reciever01d.mdl
--models/props_c17/pulleywheels_small01.mdl
--models/props_lab/tpplug.mdl