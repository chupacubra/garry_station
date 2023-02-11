GS_EntityList.ent_container = {
    cardboard_box = { 
        entity_base = "gs_entity_base_container",
        Entity_Data = {
            Name = "Cardboard box",
            Desc = "You can put something in it",
            Model = "models/props_junk/cardboard_box001a.mdl",
        },
        Private_Data = {
            Max_Items = 6,
            Items = {},
        },
    },
    wooden_box = {
        entity_base = "gs_entity_base_container",
        Entity_Data = {
            Name = "Wooden box",
            Desc = "You can put something in it",
            Model = "models/props_junk/wood_crate001a.mdl",
        },
        Private_Data = {
            Max_Items = 8,
            Items = {}
        },
    },
    fridge = { 
        entity_base = "gs_entity_base_container",
        Entity_Data = {
            Name = "Fridge",
            Desc = "Cold inside",
            Model = "models/props_c17/FurnitureFridge001a.mdl",
        },
        Private_Data = {
            Max_Items = 10,
            Items = {},
        },
    },
}
--models/props_junk/wood_crate001a.mdl