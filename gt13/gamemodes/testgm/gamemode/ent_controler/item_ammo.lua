ammo_name = {
    pistol = {
        Entity_Data = {
            Name = "Pistol ammo box",
            Desc = "Rounds 9MM.",
            Model = "models/Items/BoxSRounds.mdl",
            ENUM_Type = GS_ITEM_AMMOBOX,
            ENUM_Subtype = AMMO_9MM,
            ENT_Name = "pistol_ab",
            Simple_Examine = false, -- if need request data from server
            Size = ITEM_MEDIUM,
        },
        
        Private_Data = {
            AmmoInBox = 40,
            BulletDamage = {
                [D_BRUTE] = 10,
                [D_STAMINA] = 10,
            }
        },
        Examine_Data = BaseExamine.ammobox 
    },

    pistol_resin = {
        Entity_Data = {
            Name = "Pistol-resin ammo box",
            Desc = "Resine bullets for 9MM guns",
            Model = "models/Items/BoxSRounds.mdl",
            ENUM_Type = GS_ITEM_AMMOBOX,
            ENUM_Subtype = AMMO_9MM_R,
            ENT_Name = "pistol_resin_ab",
            Size = ITEM_MEDIUM,
        },
        Private_Data = {
            AmmoInBox = 40,
            BulletDamage = {
                [D_BRUTE] = 1,
                [D_STAMINA] = 30,
            }
        },
        Examine_Data = BaseExamine.ammobox 
    },

    tekov_magazine = {
        Entity_Data = {
            Name = "Tekov P9 Magazine",
            Desc = "For Tekov P9",
            ENUM_Type = GS_ITEM_AMMO_MAGAZINE,
            ENUM_Subtype = {AMMO_9MM, AMMO_9MM_R}, -- wtf
            ENT_Name = "tekov_magazine",
            Model = "models/weapons/unloaded/pist_p228_mag.mdl",
            Size = ITEM_SMALL,
        },
        Private_Data = {
            Max_Bullets = 12,
            Bullets = 0,
            Magazine = {},
        },
        Examine_Data = BaseExamine.gun_magazine

    },
    
    hn40_magazine = {
        Entity_Data = {
            Name = "HN 40 Magazine",
            Desc = "For HN 40",
            ENUM_Type = GS_ITEM_AMMO_MAGAZINE,
            ENUM_Subtype = {AMMO_9MM, AMMO_9MM_R},
            ENT_Name = "hn40_magazine",
            Model = "models/weapons/unloaded/smg_mp5_mag.mdl",
            Size = ITEM_SMALL,
        },
        Private_Data = {
            Max_Bullets = 25,
            Bullets = 0,
            Magazine = {},
        },
        Examine_Data = BaseExamine.gun_magazine
    },
    --[[
    pile_9mm = {
        Entity_Data = {
            Name = "Pile of 9MM bullets",
            Desc = "A lot of bullets",
            Model = "models/Items/357ammo.mdl",
            ENUM_Type = GS_ITEM_MATERIAL,
            ENUM_Subtype = AMMO_9MM,
        },
        Private_Data = {
            Stack = 1,
            Max_Stack = 20,
            BulletDamage = {
                [D_BRUTE] = 10,
                [D_STAMINA] = 10,
            }
        },
        Examine_Data = BaseExamine.pile_stack 
    },
    pile_9mm_r = {
        Entity_Data = {
            Name = "Pile of resin 9MM bullets",
            Desc = "A lot of bullets",
            Model = "models/Items/357ammo.mdl",
            ENUM_Type = GS_ITEM_MATERIAL,
            ENUM_Subtype = AMMO_9MM_R,
        },
        Private_Data = {

        }
    }
    -]]
}

BULLETS = {
    {  -- normal
        BulletDamage = {
            [D_BRUTE] = 10,
            [D_STAMINA] = 10,
        }
    },
    {  -- resin  
        BulletDamage = {
            [D_BRUTE] = 1,
            [D_STAMINA] = 30,
        }
    },
    
}

function fastMagazine(name, bullet, numbullets)
    if ammo_name[name] == nil then
        return false
    end

    local magazine = table.Copy(ammo_name[name])

    if bullet == nil or cantype(magazine.Entity_Data.ENUM_Subtype, bullet) == false then
        return false
    end

    if numbullets == nil then
        numbullets = magazine.Private_Data.Max_Bullets
    end
    
    local bul = BULLETS[bullet]

    
    for i = 1, numbullets do
        table.insert(magazine.Private_Data.Magazine, bul)
    end
    magazine.Private_Data.Bullets = numbullets

    return magazine
end
