ENT.Type = "anim"
ENT.Base = "gs_entity_base" 
 
ENT.PrintName		= "gs_entity_base_container"
ENT.Author			= "chupa"
ENT.Spawnable = false
ENT.Category = "gs"

ENT.Entity_Data = { 
    Name = "container",
    Desc = "container_desc",
    Model = "models/props_junk/cardboard_box001a.mdl",
    Type = "container",
    Item_Max_Size = ITEM_BIG,
}

ENT.Private_Data = {
    Max_Items = 8,
    Items = {}
}