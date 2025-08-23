SWEP.Base = "gs_base_weapon" 

SWEP.PrintName = "MP5"

SWEP.Author			    = "MP5"
SWEP.Contact			= "Epic smg"
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.Category = "Polar station: Guns"

SWEP.Primary.ClipSize       = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Sound = "weapons/mp5navy/mp5-1.wav"
SWEP.Primary.Cone = 0.04
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.Automatic    = false

//SWEP.UseHands           = true
SWEP.m_bPlayPickupSound = false
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false 

SWEP.Name = "MP5"
SWEP.Desc = "SMG weapon"

SWEP.HoldType       = "smg"  // basic holdtype

SWEP.Recoil     = 1
SWEP.RecoilUp   = 5
SWEP.ShotSpeed  = 0.5
SWEP.ShotSpread = 0.5

SWEP.WorldModel = "models/weapons/w_smg_mp5.mdl"//"models/weapons/polar_w_smg_mp5.mdl"
SWEP.WModel = "models/weapons/polar_w_smg_mp5.mdl"

SWEP.WorldModelCustom     = true
SWEP.WorldModelBonemerge  = true
SWEP.WorldModelBodyGroups = {
    ["no_mag"] = "00",
    ["mag"] = "01"
}
SWEP.WorldModelOffsets    = {
    pos = Vector(8, -1, 2),
    ang = Angle(0,-90-2, 180-10)
}
SWEP.Spawnable = true

SWEP.addPos = Vector(11, 0.05, 1)
SWEP.addAng = Angle(-8.5, 2.2, 0)
SWEP.sightPos = Vector(10, 5, 1.3)
SWEP.sightAng = Angle(-5, 5, -5)
SWEP.fakeHandRight = Vector(4, -2, 0)
SWEP.fakeHandLeft = Vector(10, -4, -7)
SWEP.Recoil = 0.4

function SWEP:PrimaryAttack()
    self:ShootBullet()
end

