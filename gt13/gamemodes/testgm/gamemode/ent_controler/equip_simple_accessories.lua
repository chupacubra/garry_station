GS_EntityList.accessory = {
    test_hat = { 
        entity_base = "gs_base_equip_accessory",
        Entity_Data = {
            Name = "Hat",
            Desc = "With dumb pompon",
            Model = "models/head_pompon/head_pompon.mdl",
            ENUM_Type = GS_ITEM_EQUIP,
            ENUM_Subtype = GS_EQUIP_HEAD,
            Simple_Examine = true,
            Size = ITEM_MEDIUM,
        },
    },
}

GS_EntityList.backpacks = {
    simple_back = { 
        entity_base = "gs_base_equip_accessory",
        Entity_Data = {
            Name = "Backpack",
            Desc = "Simple backpack",
            Model = "models/blacksnow/backpack.mdl",
            ENUM_Type = GS_ITEM_EQUIP,
            ENUM_Subtype = GS_EQUIP_BACKPACK,
            Simple_Examine = true,
            Size = ITEM_V_MEDIUM,
            Item_Max_Size =  ITEM_MEDIUM,
        },
        Private_Data = {
            Items = {},
            Max_Items = 8,
        }
    },
}

GS_EntityList.suit = {
    suit_casual = { 
        entity_base = "gs_base_equip_accessory",
        Entity_Data = {
            Name = "Casual suit",
            Desc = "Wear for lunch",
            Model = "models/props/cs_office/cardboard_box03.mdl",
            ENUM_Type = GS_ITEM_EQUIP,
            ENUM_Subtype = GS_EQUIP_SUIT,
            Simple_Examine = true,
            Size = ITEM_MEDIUM,
        },
        Private_Data = {
            suit = "casual"
        }
    },

    suit_work = { 
        entity_base = "gs_base_equip_accessory",
        Entity_Data = {
            Name = "Worker suit",
            Desc = "Wear for GRIND",
            Model = "models/props/cs_office/cardboard_box03.mdl",
            ENUM_Type = GS_ITEM_EQUIP,
            ENUM_Subtype = GS_EQUIP_SUIT,
            Simple_Examine = true,
            Size = ITEM_MEDIUM,
        },
        Private_Data = {
            suit = "work"
        }
    },
}
