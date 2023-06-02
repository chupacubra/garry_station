GS_EntityList.parts = {
    plug = { 
        Entity_Data = {
            Name = "Electronic plug",
            Desc = "Part of big machines",
            Model = "models/props_lab/tpplug.mdl",
            ENT_Name = "part_plug",
            ENUM_Type = GS_ITEM_COMMON,
            Simple_Examine = true,
            Size = ITEM_SMALL,
        },
    }, 
    p_wheel = { 
        Entity_Data = {
            Name = "Mechanic wheel",
            Desc = "Part of big machines",
            Model = "models/props_c17/pulleywheels_small01.mdl",
            ENT_Name = "part_wheel",
            ENUM_Type = GS_ITEM_COMMON,
            Simple_Examine = true,
            Size = ITEM_SMALL,
        },
    },
    p_electronic = { 
        Entity_Data = {
            Name = "Electronics",
            Desc = "Part of big machines",
            Model = "models/props_lab/reciever01d.mdl",
            ENT_Name = "part_electronic",
            ENUM_Type = GS_ITEM_COMMON,
            Simple_Examine = true,
            Size = ITEM_SMALL,
        },
    }
}


GS_EntityList.food = { 
    hotdog = { 
        Entity_Data = {
            Name = "Hot dog",
            Desc = "maked not from dogs",
            Model = "models/food/hotdog.mdl",
            ENT_Name = "food_hotdog",
            ENUM_Type = GS_ITEM_COMMON,
            ENUM_Subtype = GS_ITEM_FOOD,
            Simple_Examine = true,
            Size = ITEM_SMALL,
        },
        Private_Data = {
            food_qual = 20,
        },
        GetFunctions = function(ent_data, ply, context)
            functions = {}
            
            if context == CB_HAND then
                functions["hand_primary"] = function(ply, ent_data, ent_context)
                    ply:ChatPrint("mmm delicios rap snitch knishes")
                    player_manager.RunClass(ply, "InjectChemical","fiber", 10)
                    return false
                end
            end

            return functions
        end,

        RunFunction = function (name, ent_data, ply, context)
            local funcs = GS_EntityControler.GetFunctionsEntity(ent_data.Data_Labels.id, ent_data.Data_Labels.type, ent_data, ply, context)

            local action = funcs[name]

            if action then
                rez = action(ply, ent_data, context)
                return rez
            end
        end,
        --[[
            after send data about entity in client
            from shared files move context buttons to entity 
        
            only 3 context - HAND and FLOOR and EQUIP -- for equip
            
            if context == "EQUIP" then
                
            end
            ]]
        GetContextButtons = function(ent_data, context)
            local buttons = {}

            if context == CB_HAND then

            end

            if context == CB_FLOOR then
                local button = {
                    label = "Touch",
                    icon = "icon16/add.png", 
                    click = function()
                        print(ent_data, "touch")
                    end
                }
            end

            return buttons
        end
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