SWEP.Base = "gs_base_weapon" 

SWEP.PrintName = "Famas"

SWEP.Author			    = ""
SWEP.Contact			= "Epic smg"
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.Category = "Polar station: Guns"

SWEP.Primary.Delay          = 0.1
SWEP.Primary.ClipSize       = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Sound          = Sound("weapons/famas/famas-1.wav")
SWEP.Primary.Cone           = 0.01
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.Automatic    = false

SWEP.m_bPlayPickupSound = false
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false 

SWEP.Name = "famas"
SWEP.Desc = "famas weapon"

SWEP.HoldType       = "ar2" 

SWEP.Recoil     = 1
SWEP.RecoilUp   = 5
SWEP.ShotSpeed  = 0.5
SWEP.ShotSpread = 0.5

SWEP.WorldModel = "models/weapons/w_rif_famas.mdl"
SWEP.WModel = "models/weapons/polar_w_rif_famas2.mdl"

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

SWEP.addPos = Vector(9, -1.05, 5)
SWEP.addAng = Angle(-8, 2, 0)
SWEP.sightPos = Vector(9, 6, 1.3)
SWEP.sightAng = Angle(-10, -2.5, 0)
SWEP.fakeHandRight = Vector(12, -2, 0)
SWEP.fakeHandLeft = Vector(13, -3, -7)
SWEP.Recoil = 0.7

SWEP.Recoil = 0.4
SWEP.Size = ITEM_SMALL

SWEP.TypeBrass = "57"

SWEP.SoundClipIn = Sound("weapons/famas/famas_clipin.wav")
SWEP.SoundReload = Sound("weapons/famas/famas_forearm.wav")
SWEP.SoundClipOut = Sound("weapons/famas/famas_clipout.wav")

function SWEP:PrimaryAttack()
    //self:DevShoot()
    self:ShootBullet()
end