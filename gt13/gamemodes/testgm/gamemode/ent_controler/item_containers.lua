
GS_EntityList.ent_container_small = {
    cardboard_box = { 
        Entity_Data = {
            Name = "Small cardboard box",
            Desc = "You can put something in it",
            Model = "models/props_junk/cardboard_box003a.mdl",
            ENUM_Type = GS_ITEM_CONTAINER,
            Simple_Examine = true
        },
        Private_Data = {
            Max_Items = 6,
            Items = {},
        },
    },
}

GS_EntityList.ent_chem_container_small = {
    cardboard_box = { 
        Entity_Data = {
            Name = "Bucket",
            Desc = "Dear god...",
            Model = "models/props_junk/MetalBucket01a.mdl",
            ENUM_Type = GS_ITEM_CHEM_CONTAINER,
            Simple_Examine = true,
        },
        Private_Data = {
            Unit = 0,
            Max_unit = 100,
            Chem = {},
        },
    },
}