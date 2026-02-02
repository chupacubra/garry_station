SWEP.Base = "gs_base_weapon" 

SWEP.PrintName = "AK47"

SWEP.Author			    = "AK47"
SWEP.Contact			= "Epic smg"
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.Category = "Polar station: Guns"

SWEP.Primary.Delay          = 0.2
SWEP.Primary.ClipSize       = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Sound          = Sound("weapons/ak47/ak47-1.wav")
SWEP.Primary.Cone           = 0.03
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.Automatic    = false

SWEP.m_bPlayPickupSound = false
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false 

SWEP.Name = "AK47"
SWEP.Desc = "ak weapon"

SWEP.HoldType       = "ar2" 

SWEP.Recoil     = 1
SWEP.RecoilUp   = 5
SWEP.ShotSpeed  = 0.5
SWEP.ShotSpread = 0.5

SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"
SWEP.WModel = "models/weapons/polar_w_rif_ak47.mdl"

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
SWEP.addAng = Angle(-7, 2, 0)
SWEP.sightPos = Vector(7, 5, 1.25)
SWEP.sightAng = Angle(-0, -2.5, 0)
SWEP.fakeHandRight = Vector(12, -2, 0)
SWEP.fakeHandLeft = Vector(13, -3, -5)

SWEP.Size = ITEM_SMALL

SWEP.TypeBrass = "762Nato"

SWEP.SoundClipIn = Sound("weapons/ak47/ak47_clipin.wav")
SWEP.SoundReload = Sound("weapons/ak47/ak47_boltpull.wav")
SWEP.SoundClipOut = Sound("weapons/ak47/ak47_clipout.wav")

function SWEP:PrimaryAttack()
    //self:DevShoot()
    self:ShootBullet()
end