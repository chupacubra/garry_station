SWEP.Base = "gs_weapon_base" 
SWEP.HoldType = "shotgun"		-- how others view you carrying the weapon
SWEP.ViewModel = "models/weapons/cstrike/c_pist_p228.mdl"	-- Weapon view model
SWEP.WorldModel = "models/weapons/w_pist_p228.mdl"	-- Weapon world model
--SWEP.Primary.Ammo = "Pistol"

SWEP.UnloadedWorldModel = "models/weapons/unloaded/pist_p228.mdl"
SWEP.LoadedWorldModel   = "models/weapons/w_pist_p228.mdl"

SWEP.IsGS_Weapon = true
SWEP.CanPickup = true

SWEP.Primary.Sound	= Sound("weapons/p228/p228-1.wav")
SWEP.ReloadSound	= "Weapon_SMG1.Reload"
SWEP.Primary.Automatic = false
SWEP.EmptySound    = "weapons/pistol/pistol_empty.wav"

SWEP.ammo_type   = "shotgun_shell"
SWEP.shoot_speed = 1
SWEP.recoil = 4
SWEP.spread = 0.5

SWEP.action_type = GS_AW_PUMP

SWEP.m_WeaponDeploySpeed = 1

SWEP.Entity_Data = {}
SWEP.Entity_Data.Name = "Tekov P9"
SWEP.Entity_Data.Desc  = "The most popular pistol for hijacking a id card."
SWEP.Entity_Data.ENUM_Type = GS_ITEM_WEAPON
SWEP.Entity_Data.ENUM_Subtype = GS_W_SHOTGUN
SWEP.Entity_Data.Size = ITEM_SMALL
