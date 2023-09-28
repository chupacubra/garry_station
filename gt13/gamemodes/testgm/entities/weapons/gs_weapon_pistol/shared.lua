SWEP.Base = "gs_weapon_base" 
SWEP.HoldType = "pistol"		-- how others view you carrying the weapon
SWEP.ViewModel = "models/weapons/cstrike/c_pist_p228.mdl"	-- Weapon view model
SWEP.WorldModel = "models/weapons/w_pist_p228.mdl"	-- Weapon world model
--SWEP.Primary.Ammo = "Pistol"

SWEP.UnloadedWorldModel = "models/weapons/unloaded/pist_p228.mdl"
SWEP.LoadedWorldModel   = "models/weapons/w_pist_p228.mdl"
SWEP.HaveUnloadModel = true

SWEP.IsGS_Weapon = true
SWEP.CanPickup = true

SWEP.Primary.Sound	= Sound("weapons/p228/p228-1.wav")
SWEP.ReloadSound	= "Weapon_SMG1.Reload"
SWEP.Primary.Automatic = false
SWEP.EmptySound    = "weapons/pistol/pistol_empty.wav"

SWEP.ammo_type   = "tekov_magazine"
SWEP.shoot_speed = 0.5
SWEP.recoil = 1
SWEP.spread = 0.02

SWEP.action_type = GS_AW_MAGAZINE

SWEP.CanZoom = true
SWEP.ZoomOffset = Vector(-5.78, -2.52, 2.712)
SWEP.ZoomAng    = Angle()

SWEP.m_WeaponDeploySpeed = 1

SWEP.Entity_Data = {}
SWEP.Entity_Data.Name = "Tekov P9"
SWEP.Entity_Data.Desc  = "The most popular pistol for hijacking a id card."
SWEP.Entity_Data.ENUM_Type = GS_ITEM_WEAPON
SWEP.Entity_Data.ENUM_Subtype = GS_W_PISTOL
SWEP.Entity_Data.Size = ITEM_SMALL
