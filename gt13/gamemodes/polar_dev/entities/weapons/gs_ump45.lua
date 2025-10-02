SWEP.Base = "gs_base_weapon" 

SWEP.PrintName = "UMP"

SWEP.Author			    = "UMP"
SWEP.Contact			= "Epic smg"
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.Category = "Polar station: Guns"

SWEP.Primary.ClipSize       = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Sound          = "weapons/mp5navy/mp5-1.wav"
SWEP.Primary.Cone           = 0.04
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.Automatic    = false

SWEP.m_bPlayPickupSound = false
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false 

SWEP.Name = "UMP"
SWEP.Desc = "SMG weapon"

SWEP.HoldType       = "smg" 

SWEP.Recoil     = 1
SWEP.RecoilUp   = 5
SWEP.ShotSpeed  = 0.5
SWEP.ShotSpread = 0.5

SWEP.WorldModel = "models/weapons/w_smg_mp5.mdl"
SWEP.WModel = "models/weapons/polar_w_smg_ump45.mdl"

SWEP.WorldModelCustom     = true
SWEP.WorldModelBonemerge  = true
SWEP.WorldModelBodyGroups = {
    ["no_mag"] = "00",
    ["mag"] = "01"
}
SWEP.WorldModelOffsets    = {
    pos = Vector(6, -1, 4),
    ang = Angle(0,-90-2, 180-10)
}

SWEP.WorldModelDrawOffset = {
    ang = Angle(0, -90, 0),
    pos = Vector()
}

SWEP.Spawnable = true

SWEP.addPos = Vector(8, -0.9, 5)
SWEP.addAng = Angle(-9.8, 2, 0)
SWEP.sightPos = Vector(6, 8, 1)
SWEP.sightAng = Angle(-5, -2, 0)
SWEP.fakeHandRight = Vector(6, -2, 0)
SWEP.fakeHandLeft = Vector(10, -3, -5)

SWEP.Size = ITEM_SMALL

SWEP.TypeBrass = "9mm"


function SWEP:PrimaryAttack()
    //self:DevShoot()
    self:ShootBullet()
end