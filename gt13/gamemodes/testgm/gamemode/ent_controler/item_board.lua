GS_EntityList.tech_plate = {
    vendomat = { 
        Entity_Data = {
            Name = "Vendomate machine board",
            Desc = "Need for creating vendomate",
            Model = "models/props/cs_office/computer_caseb_p3a.mdl",
            ENT_Name = "board_vendomat",
            ENUM_Type = GS_ITEM_BOARD,
            ENUM_Subtype = GS_BOARD_MACHINE,
            Simple_Examine = true,
            Size = ITEM_SMALL,
        },
        Private_Data = {
            Machine = "gs_entity_vendomat",
            Parts = {
                gs_item_parts_plug = 1, 
                gs_item_parts_p_electronic = 2,
            },
        },
    },
    fabricator = { 
        Entity_Data = {
            Name = "Fabricator machine board",
            Desc = "Need for creating fabricator machine",
            Model = "models/props/cs_office/computer_caseb_p3a.mdl",
            ENT_Name = "board_fabricator",
            ENUM_Type = GS_ITEM_BOARD,
            ENUM_Subtype = GS_BOARD_MACHINE,
            Simple_Examine = true,
            Size = ITEM_SMALL,
        },
        Private_Data = {
            Machine = "gs_machine_fabricator",
            Parts = {
                gs_item_parts_plug = 1, 
                gs_item_parts_p_electronic = 2,
            },
        },
    }
}
 
GS_EntityList.pc_plate = {
    cargo_order = {
        Entity_Data = {
            Name = "Cargo order console board",
            Desc = "Need for creating cargo order console ",
            Model = "models/props/cs_office/computer_caseb_p3a.mdl",
            ENT_Name = "board_cargo_order",
            ENUM_Type = GS_ITEM_BOARD,
            ENUM_Subtype = GS_BOARD_COMPUTER,
            Simple_Examine = true,
            Size = ITEM_SMALL,
        },
        Plate_functions = {
            --[[
                arg[1] = ply
                arg[2] = ent
                arg[next] = arguments
                ]]

            setup = function(ply, ent, arg)
                return {
                    access = CARGO_ACCESS, -- place holder
                    --insert_id = false,
                    --insert_limit = 0,
                }
            end,

            itemUpdate = function(ply, ent, arg)

            end,

            order = function(ply, ent, arg)
                print(ply, ent, arg)
            end,

            getOrders = function(ply, ent, arg)

            end,

            removeOrder = function(ply, ent, arg)

            end,

            clientUpdate = function(ply, ent, arg)

            end
        }
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

