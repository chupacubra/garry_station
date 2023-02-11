GS_EntityList.resource = {
    wood = {
        Entity_Data = {
            Name = "Wood",
            Desc = "wood...",
            Model = "models/props_debris/wood_board06a.mdl",
            ENT_Name = "pile_wood",
            ENUM_Type = GS_ITEM_MATERIAL,
            --ENUM_Subtype = GS_ITEM_COMMON,
        },
        Private_Data = {
            Stack = 1,
            Max_Stack = 20,
        },
        Examine_Data = BaseExamine.pile_stack
    }
}