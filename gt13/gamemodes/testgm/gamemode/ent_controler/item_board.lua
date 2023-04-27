GS_EntityList.tech_plate = {
    vendomat = { 
        Entity_Data = {
            Name = "Vendomate machine board",
            Desc = "Need for creating vendomate",
            Model = "models/props/cs_office/computer_caseb_p3a.mdl",
            ENT_Name = "board_vendomat",
            ENUM_Type = GS_ITEM_BOARD,
            Simple_Examine = true,
            Size = ITEM_SMALL,
        },
        Private_Data = {
            Machine = "gs_entity_vendomat",
            Parts = {
                part_plug = 1, 
                part_electronic = 2,
            },
        },
    }
}

--[[
    cool models for plates
    models/props/cs_office/computer_caseb_p3a.mdl small
    models/props/cs_office/computer_caseb_p2a.mdl small
    models/props/cs_office/computer_caseb_p4a.mdl block with cooler
    models/props/cs_office/computer_caseb_p7a.mdl big plate
    models/props/cs_office/computer_caseb_p8a.mdl xsas
    models/props/cs_office/computer_caseb_p6a.mdl harddrive 
    models/props/cs_office/computer_caseb_p5a.mdl rom plate verysmol
]]