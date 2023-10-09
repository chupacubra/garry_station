-- base name for typos 
--    backpacks
--    hats
--    vest
--    belt
--    mask
--    goggles
--    ears
--    pda
--
--    id is not base equip

GS_EntityList.hats = {
    test_hat = { 
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

GS_EntityList.goggles = {
    med_glasses = { 
        Entity_Data = {
            Name = "Medical glasses",
            Desc = "Now piple cant hide burns and cut",
            Model = "models/glasses_oakley/glasses_oakley.mdl",
            ENT_Name = "med_glasses",
            ENUM_Type = GS_ITEM_EQUIP,
            ENUM_Subtype = GS_EQUIP_EYES,
            Simple_Examine = true,
            Size = ITEM_VERY_SMALL,
        },
        CL_EQ_Func = {
            OnEquip = function()
                -- start equip function
            end,
            OnDrop = function()
                --
            end,
            DrawHUD = function()
                -- new day - new bad ideas
                -- we chosed to split client/server info - now its kick me in teeths

                if MED_GLASS_ARRAY == nil then
                    MED_GLASS_TIMER = MED_GLASS_TIMER or CurTime() + 1
                    MED_GLASS_ARRAY = MED_GLASS_ARRAY or {}
                end

                if MED_GLASS_TIMER < CurTime() then
                    net.Start("gs_equip_functions")
                    net.WriteUInt(GS_EQUIP_EYES, 4)
                    net.WriteString("med_glasses")
                    net.WriteString("sensor")
                    net.SendToServer()
                    MED_GLASS_TIMER = CurTime() + 1
                end

                --if table.IsEmpty(MED_GLASS_ARRAY) then return end
                for i = 1, #MED_GLASS_ARRAY do
                    local draw_data = MED_GLASS_ARRAY[i]
                    local pos = draw_data.pos:ToScreen()
                    --surface.SetDrawColor( 255, 0, 0 )
                    --surface.DrawOutlinedRect( pos.x, pos.y, 75, 50, 1)
                    surface.SetTextColor( GetProcentColor(draw_data.hp))
                    surface.SetTextPos( pos.x+10, pos.y+10 )
                    surface.DrawText(tostring(draw_data.hp).. "%")
                end
            end
        },
        SV_EQ_Func = {
            sensor = function(owner)
                -- return to owner info about health people on some distance
                -- sending info in order
                -- 0. Amount of (max 10)
                -- 1. Entity 1
                -- 2. HP %
                -- 3. Entity 2
                -- 4. ...
                local arr = {}
                
                for _, ply in pairs(ents.FindInSphere( owner:GetPos(), 250 )) do
                    if #arr == 10 then break end
                    --if ply == owner then continue end
                    if ply:IsPlayer() then
                        arr[ply] = player_manager.RunClass(ply, "GetSumDMG")
                    end
                end

                net.Start("gs_eq_med_glasses_sensors")
                net.WriteUInt(table.Count(arr), 4)
                for k, v in pairs(arr) do
                    net.WriteEntity(k)
                    net.WriteInt(v, 11)
                end
                net.Send(owner)

            end
        }
    },
}

GS_EntityList.vest = {
    --[[
    armor_vest = { 
        Entity_Data = {
            Name = "Bulletproof vest",
            Desc = "To be honest, I wouldn't have much hope for him.",
            Model = "models/glasses_oakley/glasses_oakley.mdl",
            ENUM_Type = GS_ITEM_EQUIP,
            ENUM_Subtype = GS_EQUIP_VEST,
            Simple_Examine = true,
            Size = ITEM_V_MEDIUM,
            Item_Max_Size =  ITEM_MEDIUM,
        },
        Private_Data = {
            Armor_Setting = {
                Protection = 20,
                -- Ex: Final damage = Damage - Protection
                -- if Final damage <= 0:
                --     Armor softened the impact
                -- else > 0:
                --     Armor was pierced!
            }
        }
    },
    --]]
}

GS_EntityList.suit = {
    suit_casual = { 
        --entity_base = "gs_base_equip_accessory",
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

-- some day, one people must be refactored all code

Equip_ENUM_To_Names = {
    [GS_EQUIP_BACKPACK] = "backpacks",
    --GS_EQUIP_ID       = 2
    --GS_EQUIP_PDA      = 3
    --GS_EQUIP_BELT     = 4
    [GS_EQUIP_EYES]     = "goggles",
    --GS_EQUIP_VEST     = 6
    [GS_EQUIP_HEAD]     = "hats",
    --GS_EQUIP_MASK     = 8
    --GS_EQUIP_EAR      = 9
    --GS_EQUIP_SUIT     = 10
}

net.Receive("gs_equip_functions", function(_, ply)
    local eq = net.ReadUInt(4)
    local name = net.ReadString()
    local func = net.ReadString()

    local tp = Equip_ENUM_To_Names[eq]

    -- HERE need check function about have this piple equipments

    --print(eq, name, func, tp)
    GS_EntityList[tp][name]["SV_EQ_Func"][func](ply)
end)

-- Появилась мощная идея функции создания снаряги
-- CreateNewEquipment(таблица, со всеми данными, таблица для cl_equip_config.lua )

-- nice model fro EFT equip
-- backpacks civ
-- models/backpack_sanitar_medbag/backpack_sanitar_medbag.mdl
-- models/backpack_redfox/backpack_redfox.mdl
-- models/backpack_sportbag/backpack_sportbag.mdl
-- models/backpack_daypack/backpack_daypack.mdl 
--
-- armor vest
-- models/armor_custom_thorcrv/ar_thorcrv.mdl
-- models/armor_slick/armor_slick_black.mdl

AddEquipment("vest", "armor_vest",
    { 
        Entity_Data = {
            Name = "Bulletproof vest",
            Desc = "To be honest, I wouldn't have much hope for him.",
            Model = "models/armor_custom_thorcrv/ar_thorcrv.mdl",
            ENUM_Type = GS_ITEM_EQUIP,
            ENUM_Subtype = GS_EQUIP_VEST,
            Simple_Examine = true,
            Size = ITEM_V_MEDIUM,
            Item_Max_Size =  ITEM_MEDIUM,
        },
        Private_Data = {
            Armor_Setting = {
                Protection = 20,
            }
        }
    },
    {
        vec = Vector(-5, 4, 0),
        ang = Angle(180, -90, -90),
        bone = "ValveBiped.Bip01_Spine2",
        armor = AR_VEST,
    }
)

AddEquipment("belt", "unloading_vest",
    { 
        Entity_Data = {
            Name = "Unloading vest",
            Desc = "For storing various military gadgets, but in general for magazines",
            Model = "models/armor_custom_thorcrv/ar_thorcrv.mdl",
            ENUM_Type = GS_ITEM_EQUIP,
            ENUM_Subtype = GS_EQUIP_BELT,
            Simple_Examine = true,
            Size = ITEM_MEDIUM,
            Item_Max_Size =  ITEM_SMALL,
        },
        Private_Data = {
            Items = {},
            Max_Items = 8,
            Unloading_Ammo = true, -- for fast access for ammo magazines (only R and you a reloading)
        }
    },
    {
        vec = Vector(-5, 4, 0),
        ang = Angle(180, -90, -90),
        bone = "ValveBiped.Bip01_Spine2",
        armor = AR_VEST,
    }
)

AddEquipment("hats", "helmet",
    { 
        Entity_Data = {
            Name = "Bulletproof helmet",
            Desc = "Better with a helmet than without it.",
            Model = "models/helmet_ulach_black/ulach.mdl",
            ENUM_Type = GS_ITEM_EQUIP,
            ENUM_Subtype = GS_EQUIP_HEAD,
            Simple_Examine = true,
            Size = ITEM_V_MEDIUM,
            Item_Max_Size =  ITEM_MEDIUM,
        },
        Private_Data = {
            Armor_Setting = {
                Protection = 20,
            }
        }
    },
    {
        vec = Vector(-2, -2, 0),
        ang = Angle(0, -80, -90),
        bone = "ValveBiped.Bip01_Head1",
        armor = AR_MET,
    }
)