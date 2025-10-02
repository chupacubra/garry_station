SWEP.Base = "gs_base_weapon" 

SWEP.PrintName = "Para"

SWEP.Author			    = ""
SWEP.Contact			= "Epic smg"
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.Category = "Polar station: Guns"

SWEP.Primary.ClipSize       = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Sound          = "weapons/m249/m249-1.wav"
SWEP.Primary.Cone           = 0.04
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.Automatic    = false

SWEP.m_bPlayPickupSound = false
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false 

SWEP.Name = "Para"
SWEP.Desc = "big weapon"

SWEP.HoldType       = "ar2" 

SWEP.Recoil     = 1
SWEP.RecoilUp   = 5
SWEP.ShotSpeed  = 0.5
SWEP.ShotSpread = 0.5

SWEP.WorldModel = "models/weapons/w_mach_m249para.mdl"
SWEP.WModel = "models/weapons/polar_w_mach_m249para.mdl"

SWEP.WorldModelCustom     = true
SWEP.WorldModelBonemerge  = true
SWEP.WorldModelBodyGroups = {
    ["no_mag"] = "00",
    ["mag"] = "01"
}
SWEP.WorldModelOffsets    = {
    pos = Vector(13, -1, 2),
    ang = Angle(0,-90-2, 180-10)
}

SWEP.WorldModelDrawOffset = {
    ang = Angle(0, 90, 0),
    pos = Vector()
}
SWEP.Spawnable = true


SWEP.addPos = Vector(15, -1, 5)
SWEP.addAng = Angle(-11, 1.5, 0)
SWEP.sightPos = Vector(7, 6, 0.8)
SWEP.sightAng = Angle(-5, -2.5, 0)
SWEP.fakeHandRight = Vector(12, -2, 0)
SWEP.fakeHandLeft = Vector(13, -3, -5)

SWEP.Recoil = 0.8
SWEP.Size = ITEM_SMALL

SWEP.TypeBrass = "556"


function SWEP:PrimaryAttack()
    //self:DevShoot()
    self:ShootBullet()
end