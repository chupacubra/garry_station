SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""
SWEP.SlotPos        = 0
SWEP.GS_Hand = true
SWEP.HoldType				= "normal"
SWEP.Category			    = "Other"

SWEP.Spawnable              = true
SWEP.AdminSpawnable         = true

SWEP.ViewModel = "models/weapons/c_arms.mdl" 
SWEP.WorldModel = ""
SWEP.UseHands = true
SWEP.DrawAmmo = false

function FormatDataForCLHands(tbl)
    return table.concat( tbl, "," )
end

function DeformatDataForCLHands(str)
    return string.Explode(",", str)
end
