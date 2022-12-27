ammo_name = {
    pistol = {
        Entity_Data = {
        Name = "Pistol ammo box",
        Desc = "Rounds 9MM for pistols.",
        Model = "models/Items/BoxSRounds.mdl",
        ENUM_Type = GS_ITEM_AMMOBOX,
        ENUM_Subtype = AMMO_9MM,
        AmmoInBox = 40,
        },
        
        Private_Data = {
            BulletDamage = {
                [D_BRUTE] = 10,
                [D_STAMINA] = 10,
            }
        }
    },

    pistol_resin = {
        Entity_Data = {
            Name = "Pistol-resin ammo box",
            Desc = "Resine bullets for 9MM guns",
            Model = "models/Items/BoxSRounds.mdl",
            ENUM_Type = GS_ITEM_AMMOBOX,
            ENUM_Subtype = AMMO_9MM_R,
            AmmoInBox = 40,
        },
        Private_Data = {
            BulletDamage = {
                [D_BRUTE] = 1,
                [D_STAMINA] = 30,
            }
        }
    },
    pistol_magazine = {
        Entity_Data = {
            Name = "Pistol magazine",
            Desc = "For Tekov P9",
            ENUM_Type = GS_ITEM_AMMO_MAGAZINE,
            ENUM_Subtype = {AMMO_9MM, AMMO_9MM_R},
            Weapon_Magazine = "tekov_magazine",
            Model = "models/weapons/unloaded/pist_p228_mag.mdl",
        },
        Private_Data = {
            Max_Bullets = 12,
            AmmoInMagazine = {},
        },
    },
}
