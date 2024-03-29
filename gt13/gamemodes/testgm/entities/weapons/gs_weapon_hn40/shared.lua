SWEP.Base = "gs_weapon_base" 
SWEP.HoldType = "smg"
SWEP.ViewModel = "models/weapons/cstrike/c_smg_mp5.mdl"
SWEP.WorldModel =  "models/weapons/w_smg_mp5.mdl"

SWEP.UnloadedWorldModel = "models/weapons/unloaded/smg_mp5.mdl"
SWEP.LoadedWorldModel   = "models/weapons/w_smg_mp5.mdl"
SWEP.HaveUnloadModel    = true

SWEP.IsGS_Weapon = true
SWEP.CanPickup = true

SWEP.Primary.Sound	= Sound("weapons/mp5navy/mp5-1.wav")
SWEP.ReloadSound	= "Weapon_SMG1.Reload"
SWEP.Primary.Automatic = true
SWEP.EmptySound    = "weapons/pistol/pistol_empty.wav"

SWEP.ammo_type   = "hn40_magazine"
SWEP.shoot_speed = 0.1
SWEP.recoil = 1
SWEP.spread = 0.02

SWEP.action_type = GS_AW_MAGAZINE

SWEP.CanZoom = true
SWEP.ZoomOffset = Vector(-5.3, -6.662, 2.0)
SWEP.ZoomAng    = Angle(1, 0, 0)

SWEP.m_WeaponDeploySpeed = 1

SWEP.Entity_Data = {}
SWEP.Entity_Data.Name = "HN 40"
SWEP.Entity_Data.Desc  = "A favorite machine among bodyguards and killers."
SWEP.Entity_Data.ENUM_Type = GS_ITEM_WEAPON
SWEP.Entity_Data.ENUM_Subtype = GS_W_SMG
SWEP.Entity_Data.Size = ITEM_MEDIUM

