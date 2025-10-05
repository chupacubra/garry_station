SWEP.Base = "gs_base_weapon" 

SWEP.PrintName = "USP"

SWEP.Author			    = ""
SWEP.Contact			= "Epic smg"
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.Category = "Polar station: Guns"

SWEP.Primary.Delay          = 0.1
SWEP.Primary.ClipSize       = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Sound          = Sound("weapons/tmp/tmp-1.wav")
SWEP.Primary.Cone           = 0.01
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.Automatic    = false

SWEP.m_bPlayPickupSound = false
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false 

SWEP.Name = "USP"
SWEP.Desc = "pistol weapon"

SWEP.HoldType       = "revolver" 

SWEP.Recoil     = 0.5
SWEP.RecoilUp   = 5
SWEP.ShotSpeed  = 0.5
SWEP.ShotSpread = 0.5

SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.WModel = "models/weapons/w_pist_usp_silencer.mdl"

SWEP.WorldModelCustom     = true
SWEP.WorldModelBonemerge  = true
SWEP.WorldModelBodyGroups = {
    ["no_mag"] = "00",
    ["mag"] = "01"
}
SWEP.WorldModelOffsets    = {
    pos = Vector(2.5, -2, 2),
    ang = Angle(0,0, 180)
}

SWEP.WorldModelDrawOffset = {
    ang = Angle(0, 180, 0),
    pos = Vector(2,0,-5)
}


SWEP.Spawnable = true

SWEP.addPos = Vector(10, -1.5, 0)
SWEP.addAng = Angle(0, 0, 0)
SWEP.sightPos = Vector(4.8, 5, -0.35)
SWEP.sightAng = Angle(0, 0, 0)
SWEP.fakeHandRight = Vector(3.5, -1.5, 2)

SWEP.Recoil = 0.4
SWEP.Size = ITEM_SMALL

SWEP.TypeBrass = "9mm"
SWEP.Silenced = true

SWEP.SoundClipIn = Sound("weapons/usp/usp_clipin.wav")
SWEP.SoundReload = Sound("weapons/usp/usp_slideback.wav")
SWEP.SoundClipOut = Sound("weapons/usp/usp_clipout.wav")

function SWEP:PrimaryAttack()
    //self:DevShoot()
    self:ShootBullet()
end