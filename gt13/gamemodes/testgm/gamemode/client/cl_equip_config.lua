AR_VEST = 0
AR_MET  = 1
cl_equip_config = cl_equip_config or {}

cl_equip_config["models/blacksnow/backpack.mdl"] = {
    vec = Vector( 0, -2, 0 ),
    ang = Angle( 0, 0, 90 ),
    bone = "ValveBiped.Bip01_Spine2",
}

cl_equip_config["models/head_pompon/head_pompon.mdl"] = {
    vec = Vector(2, 0.9, 0),
    ang = Angle(0, -90, -90),
    bone = "ValveBiped.Bip01_Head1",
}

cl_equip_config["models/glasses_oakley/glasses_oakley.mdl"] = {
    vec = Vector(2, 0.9, 0),
    ang = Angle(0, -90, -90),
    bone = "ValveBiped.Bip01_Head1",
}