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

SWEP.UseHands = true

SWEP.IsGS_Weapon = true 
SWEP.CanExamine  = true

SWEP.Primary.Automatic = false
--SWEP.Primary.Sound = ""
SWEP.PrimarySound = "Weapon_Crowbar"

SWEP.Entity_Data = {}
SWEP.Entity_Data.Name = "tool"
SWEP.Entity_Data.Desc = "desc"
SWEP.Entity_Data.ENUM_Type = GS_ITEM_TOOL
SWEP.Entity_Data.Type = "toolname"

SWEP.Private_Data = {}
SWEP.Damage = {7,2}

SWEP.MissSound = util.PrecacheSound( SWEP.PrimarySound..".Single" )
SWEP.HitSound = util.PrecacheSound(SWEP.PrimarySound..".Melee_HitWorld")
