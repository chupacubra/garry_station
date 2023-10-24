GS_EntityList.shotgun_ammo = {
    shotgun_shot = {
        Entity_Data = {
            Name = "Shotgun shells box",
            Desc = "who are you going to hunt?",
            Model = "models/Items/BoxBuckshot.mdl",
            ENT_Name = "shotgunshot",
            ENUM_Type = GS_ITEM_AMMO_PILE,
            ENUM_Subtype = GS_W_SHOTGUN,
            Size = ITEM_SMALL,
        },
        Private_Data = {
            Stack = 8,
            Max_Stack = 20,
            Bullet = Bullets_Type.sh_shot,
        },
        Examine_Data = BaseExamine.ammo_pile
    },
    shotgun_slug = {
        Entity_Data = {
            Name = "Shotgun slug box",
            Desc = "For feral beasts",
            Model = "models/Items/BoxBuckshot.mdl",
            ENT_Name = "shotgunshot",
            ENUM_Type = GS_ITEM_AMMO_PILE,
            ENUM_Subtype = GS_W_SHOTGUN,
            Size = ITEM_SMALL,
        },
        Private_Data = {
            Stack = 8,
            Max_Stack = 20,
            Bullet = Bullets_Type.sh_shot_slug,
            ENT_Color    = rgbToHex(Color(255,255,255)),
        },
        Examine_Data = BaseExamine.ammo_pile
    }
}