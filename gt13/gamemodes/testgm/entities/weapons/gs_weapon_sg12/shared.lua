SWEP.Base = "gs_weapon_base" 
SWEP.HoldType = "shotgun"		-- how others view you carrying the weapon
SWEP.ViewModel = "models/weapons/cstrike/c_shot_m3super90.mdl"	-- Weapon view model
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"	-- Weapon world model
--SWEP.Primary.Ammo = "Pistol"

SWEP.UnloadedWorldModel = "models/weapons/w_shot_m3super90.mdl"	
SWEP.LoadedWorldModel   = "models/weapons/w_shot_m3super90.mdl"
SWEP.HaveUnloadModel = false

SWEP.IsGS_Weapon = true
SWEP.CanPickup = true

SWEP.Primary.Sound	= Sound("weapons/m3/m3-1.wav")
SWEP.ReloadSound	= Sound("Weapon_Shotgun.Reload")
SWEP.Primary.Automatic = false
SWEP.EmptySound    = Sound("weapons/pistol/shotgun_empty.wav")

SWEP.ammo_type   = "shotgun_shell"
SWEP.shoot_speed = 1
SWEP.recoil = 4
SWEP.spread = 0.5

SWEP.action_type = GS_AW_PUMP

SWEP.CanZoom = true
SWEP.ZoomOffset = Vector( -7.65, -3, 3.5 )

SWEP.m_WeaponDeploySpeed = 1

SWEP.AnimList = {
    pump_slide = 4,
}

SWEP.Entity_Data = {}
SWEP.Entity_Data.Name = "SG-12"
SWEP.Entity_Data.Desc  = "The main gun of the special forces for the invasion of someone else's property."
SWEP.Entity_Data.ENUM_Type = GS_ITEM_WEAPON
SWEP.Entity_Data.ENUM_Subtype = GS_W_SHOTGUN
SWEP.Entity_Data.Size = ITEM_MEDIUM

