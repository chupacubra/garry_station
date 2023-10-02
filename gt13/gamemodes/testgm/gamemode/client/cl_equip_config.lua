AR_VEST = 0
AR_MET  = 1

cl_equip_config = {
    ["models/blacksnow/backpack.mdl"] = {
        vec = Vector( 0, -2, 0 ),
        ang = Angle( 0, 0, 90 ),
        bone = "ValveBiped.Bip01_Spine2",
    },
    ["models/head_pompon/head_pompon.mdl"] = {
        vec = Vector(2, 0.9, 0),
        ang = Angle(0, -90, -90),
        bone = "ValveBiped.Bip01_Head1",
    },
    ["models/glasses_oakley/glasses_oakley.mdl"] = {
        vec = Vector(2, 0.9, 0),
        ang = Angle(0, -90, -90),
        bone = "ValveBiped.Bip01_Head1",
    },
    ["armorvest"] = {
        vec = Vector(2, 0.9, 0),
        ang = Angle(0, -90, -90),
        bone = "ValveBiped.Bip01_Spine2",
        armor = AR_VEST,
    },
    ["armorvest"] = {
        vec = Vector(2, 0.9, 0),
        ang = Angle(0, -90, -90),
        bone = "ValveBiped.Bip01_Head1",
        armor = AR_MET,
    }
}