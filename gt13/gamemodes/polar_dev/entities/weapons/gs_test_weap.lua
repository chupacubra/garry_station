SWEP.Base = "gs_base_weapon" 

SWEP.Author			    = "TEST WEAPON"
SWEP.Contact			= "TEST"
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.Primary.ClipSize       = -1
SWEP.Primary.Automatic      = false
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.Automatic    = false

SWEP.UseHands           = true
SWEP.m_bPlayPickupSound = false
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false 

SWEP.Name = "Skibidiweapon"
SWEP.Desc = "Palka-ubivalka"

SWEP.HoldType       = "pistol"  // basic holdtype

SWEP.Recoil     = 10
SWEP.RecoilUp   = 15
SWEP.ShotSpeed  = 0.5
SWEP.ShotSpread = 0.5

SWEP.WorldModel = "models/kali/weapons/black_ops/pm-63 rak.mdl"

SWEP.WorldModelCustom     = true
SWEP.WorldModelBonemerge  = true
SWEP.WorldModelBodyGroups = {
    ["base"] = {
        ["Foregrip"]    = "Foregrip_DN",
        ["Stock"]       = "Stock_Unfolded",
    },
    ["base2"] = {
        ["Foregrip"]    = "Foregrip_DN",
        ["Stock"]       = "Stock_Unfolded",
    }
}
SWEP.WorldModelOffsets    = {
    pos = Vector(4,-2,-2),
    ang = Angle(0,90,180)
}
SWEP.Spawnable = true