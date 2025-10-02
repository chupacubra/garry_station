SWEP.Base = "gs_base_weapon" 

SWEP.PrintName = "M16"

SWEP.Author			    = ""
SWEP.Contact			= "Epic smg"
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.Category = "Polar station: Guns"

SWEP.Primary.ClipSize       = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Sound          = "weapons/m4a1/m4a1-1.wav"
SWEP.Primary.Cone           = 0.01
SWEP.Silenced = true

SWEP.m_bPlayPickupSound = false
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false 

SWEP.Name = "M16"
SWEP.Desc = "m16 weapon"

SWEP.HoldType       = "ar2" 

SWEP.Recoil     = 1
SWEP.RecoilUp   = 5
SWEP.ShotSpeed  = 0.1
SWEP.ShotSpread = 0.1

SWEP.WorldModel = "models/weapons/w_rif_m4a1_silencer.mdl"
SWEP.WModel = "models/weapons/polar_w_rif_m4a3.mdl"

SWEP.WorldModelCustom     = true
SWEP.WorldModelBonemerge  = true
SWEP.WorldModelBodyGroups = {
    ["no_mag"] = "00",
    ["mag"] = "01"
}
SWEP.WorldModelOffsets    = {
    pos = Vector(15, -1, 1),
    ang = Angle(0,-90-2, 180-10)
}

SWEP.WorldModelDrawOffset = {
    ang = Angle(0, 90, 0),
    pos = Vector()
}

SWEP.Spawnable = true


SWEP.addPos = Vector(15, -2, 5)
SWEP.addAng = Angle(-8, 2, 0)
SWEP.sightPos = Vector(8, 5, 1.3)
SWEP.sightAng = Angle(0, -2.5, 0)
SWEP.fakeHandRight = Vector(12, -2, 0)
SWEP.fakeHandLeft = Vector(13, -3, -5)

SWEP.Size = ITEM_SMALL

SWEP.TypeBrass = "556"

function SWEP:PrimaryAttack()
    //self:DevShoot()
    self:ShootBullet()
end