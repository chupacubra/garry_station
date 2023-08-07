SWEP.Base = "gs_swep_base"
SWEP.IsGS_Weapon = true
SWEP.CanPickup = true

SWEP.Primary.Automatic = false
SWEP.PrimarySound = "Weapon_Crowbar"
SWEP.m_WeaponDeploySpeed = 1

SWEP.VElements = {
	["element_name"] = { type = "Model", model = "models/props/tier/screwdriver.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.635, 1.557, -1.558), angle = Angle(171.817, 90--[[-78.312--]], 59.61), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["element_name"] = { type = "Model", model = "models/props/tier/screwdriver.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.596, 1.557, 0), angle = Angle(174.156, 143.766, 115.713), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.ViewModelFOV = 101.70854271357
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_crowbar_frame.mdl"
SWEP.WorldModel = "models/props/tier/screwdriver.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true

SWEP.HoldType = "melee"

SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_Spine4"] = { scale = Vector(1, 1, 1), pos = Vector(-8.334, 0, 0), angle = Angle(0, 0, 0) }
}


SWEP.Entity_Data = {}
SWEP.Entity_Data.Name = "Screwdriver"
SWEP.Entity_Data.Desc  = "flathead"
SWEP.Entity_Data.ENUM_Type = GS_ITEM_TOOL
SWEP.Entity_Data.ENUM_Subtype = T_SCREWDRIVER
SWEP.Entity_Data.Model = SWEP.WorldModel

SWEP.PrimarySound = "Weapon_Crowbar"
SWEP.MissSound = Sound(SWEP.PrimarySound..".Single" )
SWEP.HitSound = Sound(SWEP.PrimarySound..".Melee_HitWorld")
