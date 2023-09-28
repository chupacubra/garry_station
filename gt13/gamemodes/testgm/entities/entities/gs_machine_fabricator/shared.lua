ENT.Type = "anim"
ENT.Base = "gs_entity_base"
 
ENT.PrintName		= "gs_fabricator"
ENT.Author			= "chupa"
ENT.Spawnable = false
ENT.Category = "gs"
ENT.GS_Machine_Type = "machine"

ENT.ConnectDist = 100


ENT.Entity_Data = {
    Name = "Fabricator",
    Desc = "For making smthng",
    Model = "models/jmod/machines/parts_machine.mdl",
    Type = "machine_case",
}

ENT.ItemReceiver = true

FABRICATOR_RECEIPTS = {
    tool = {
        name = "Tools",
        items = {
            crowbar = {
                typ = "swep",
                id  = "gs_tool_crowbar",
                craft = {
                    metal = 150
                }
            },
            wrench = {
                typ = "swep",
                id  = "gs_tool_wrench",
                craft = {
                    metal = 100
                }
            },
            screw = {
                typ = "swep",
                id  = "gs_tool_screwdriver",
                craft = {
                    metal = 50
                }
            }
        }
    },
}