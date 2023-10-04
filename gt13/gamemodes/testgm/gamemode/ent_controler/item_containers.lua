GS_EntityList.ent_container_small = {
    cardboard_box = { 
        entity_base = "gs_entity_base_item_container",
        Entity_Data = {
            Name = "Small cardboard box",
            Desc = "You can put something in it",
            Model = "models/props_junk/cardboard_box003a.mdl",
            ENUM_Type = GS_ITEM_CONTAINER,
            Simple_Examine = true,
            --[[
                how about this?
            --]]
            Item_Max_Size = ITEM_MEDIUM,
            Size = ITEM_MEDIUM,
        },
        Private_Data = {
            Max_Items = 6,
            Items = {},
        },
    },
}

GS_EntityList.ent_chem_container_small = {
    bucket = { 
        Entity_Data = {
            Name = "Bucket",
            Desc = "Dear god...",
            Model = "models/props_junk/MetalBucket01a.mdl",
            ENUM_Type = GS_ITEM_CHEM_CONTAINER,
            Size = ITEM_MEDIUM,
        },
        Private_Data = { -- TRASH
            Unit = 0,
            Max_unit = 100,
            Chem = {},
        },
        Examine_Data = BaseExamine.chem_container
    },
}