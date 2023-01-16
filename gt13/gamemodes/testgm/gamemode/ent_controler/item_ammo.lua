ammo_name = {
    pistol = {
        Entity_Data = {
            Name = "Pistol ammo box",
            Desc = "Rounds 9MM.",
            Model = "models/Items/BoxSRounds.mdl",
            ENUM_Type = GS_ITEM_AMMOBOX,
            ENUM_Subtype = AMMO_9MM,
            Simple_Examine = false -- if need request data from server
        },
        
        Private_Data = {
            AmmoInBox = 40,
            BulletDamage = {
                [D_BRUTE] = 10,
                [D_STAMINA] = 10,
            }
        },

        Examine_Data = {
            {"In box %s bullets","AmmoInBox"}
        },
        
    },

    pistol_resin = {
        Entity_Data = {
            Name = "Pistol-resin ammo box",
            Desc = "Resine bullets for 9MM guns",
            Model = "models/Items/BoxSRounds.mdl",
            ENUM_Type = GS_ITEM_AMMOBOX,
            ENUM_Subtype = AMMO_9MM_R,
        },
        Private_Data = {
            AmmoInBox = 40,
            BulletDamage = {
                [D_BRUTE] = 1,
                [D_STAMINA] = 30,
            }
        },
        Examine_Data = {
            -- the private data from
            {"In box %s bullets","AmmoInBox"}
        }
    },
    tekov_magazine = {
        Entity_Data = {
            Name = "Tekov P9 Magazine",
            Desc = "For Tekov P9",
            ENUM_Type = GS_ITEM_AMMO_MAGAZINE,
            ENUM_Subtype = {AMMO_9MM, AMMO_9MM_R},
            Weapon_Magazine = "tekov_magazine",
            Model = "models/weapons/unloaded/pist_p228_mag.mdl",
        },
        Private_Data = {
            Max_Bullets = 12,
            Bullets = 0,
            Magazine = {},
        },
        Examine_Data = {
            {"In magazine %s bullets", "Bullets"}
        },

    },
    hn40_magazine = {
        Entity_Data = {
            Name = "HN 40 Magazine",
            Desc = "For HN 40",
            ENUM_Type = GS_ITEM_AMMO_MAGAZINE,
            ENUM_Subtype = {AMMO_9MM, AMMO_9MM_R},
            Weapon_Magazine = "hn40_magazine",
            Model = "models/weapons/unloaded/smg_mp5_mag.mdl",
        },
        Private_Data = {
            Max_Bullets = 25,
            Bullets = 0,
            Magazine = {},
        },
        Examine_Data = {
            {"In magazine %s bullets", "Bullets"}
        },
    },
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
        Examine_Data = {
            {"In pile %s items", "Stack"}
        }
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
}

BULLETS = {
    {
        BulletDamage = {
            [D_BRUTE] = 10,
            [D_STAMINA] = 10,
        }
    },
    {             
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
    print(bullet)
    if bullet == nil or cantype(magazine.Entity_Data.ENUM_Subtype, bullet) == false then
        return false
    end

    if numbullets == nil then
        numbullets = magazine.Private_Data.Max_Bullets
    end
    
    local bul = BULLETS[bullet]

    print(bul, bullet)
    for i = 1, numbullets do
        table.insert(magazine.Private_Data.Magazine, bul)
    end
    magazine.Private_Data.Bullets = numbullets
    print(numbullets)
    PrintTable(magazine)
    return magazine
end
