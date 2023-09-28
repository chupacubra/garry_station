GS_EntityList.shotgun_ammo = {
    wood = {
        Entity_Data = {
            Name = "Shotgun shells box",
            Desc = "who are you going to hunt?",
            Model = "#shotgunammobox",
            ENT_Name = "shotgunshot",
            ENUM_Type = GS_ITEM_AMMO_PILE,
            ENUM_Subtype = GS_W_SHOTGUN,
            Size = ITEM_SMALL,
        },
        Private_Data = {
            Stack = 1,
            Max_Stack = 20,
            Bullet = Bullets_Type.sh_shot,
        },
        Examine_Data = BaseExamine.ammo_pile
    }
}