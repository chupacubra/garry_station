SWEP.Author			    = ""
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.Spawnable			= false 
SWEP.AdminSpawnable		= false
SWEP.Category           = "GS"
SWEP.SlotPos            = 1

SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.UnloadedWorldModel = ""
SWEP.LoadedWorldModel   = ""
SWEP.HaveUnloadModel = true

SWEP.UseHands = true

SWEP.IsGS_Weapon = true 
SWEP.CanExamine  = true

SWEP.Primary.Automatic = false
SWEP.Primary.Sound = ""
SWEP.EmptySound    = ""

SWEP.ammo_type   = ""
SWEP.shoot_speed = 0.5
SWEP.recoil = 1
SWEP.spread = 0.3
SWEP.damage = 10
SWEP.damage_type = D_BRUTE
SWEP.action_type = ""

SWEP.AnimList = {
    -- idle = 0,
    -- reload = 1,
    
}

SWEP.CanZoom = false
SWEP.ZoomOffset = Vector()
SWEP.ZoomAng    = Angle()

SWEP.Entity_Data = {}
SWEP.Entity_Data.Name = "weapon"
SWEP.Entity_Data.Desc = "desc"
SWEP.Entity_Data.ENUM_Type = GS_ITEM_WEAPON
SWEP.Entity_Data.ENUM_Subtype = GS_W_PISTOL

SWEP.Private_Data = {
    Ammo = nil
}
