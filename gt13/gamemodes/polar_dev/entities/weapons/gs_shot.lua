SWEP.Base = "gs_base_weapon_shot" 

SWEP.PrintName = "Shotgun"

SWEP.Author			    = "12G Pump Action"
SWEP.Contact			= "Epic drobodan"
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.Category = "Polar station: Guns"

SWEP.Primary.Delay          = 0.5
SWEP.Primary.ClipSize       = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Sound          = Sound("weapons/shotgun/shotgun_fire7.wav")
SWEP.Primary.Cone           = 0.1
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.Automatic    = false

SWEP.m_bPlayPickupSound = false
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false 

SWEP.Name = "12G Pump Action"
SWEP.Desc = "drob weapon"

SWEP.HoldType       = "ar2" 

SWEP.Recoil     = 2
SWEP.RecoilUp   = 5
SWEP.ShotSpeed  = 0.5
SWEP.ShotSpread = 0.5

SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.WModel = "models/weapons/w_shotgun.mdl"

SWEP.WorldModelCustom     = true
SWEP.WorldModelBonemerge  = true
SWEP.WorldModelBodyGroups = {
    ["no_mag"] = "00",
    ["mag"] = "01"
}
SWEP.WorldModelOffsets    = {
    pos = Vector(17, 0, -3), --Vector(13, -1, 2),
    ang = Angle(180 + 10,0,0)//Angle(0,-90-2, 180-10)
}

SWEP.WorldModelDrawOffset = {
    ang = Angle(), 
    pos = Vector()
}
SWEP.Spawnable = true

SWEP.addPos = Vector(15, -1, 5)
SWEP.addAng = Angle(-3, -2, 0)
SWEP.sightPos = Vector(7, 5, 0.2)
SWEP.sightAng = Angle(-0, -5, 0)
SWEP.fakeHandRight = Vector(12, -2, 0)
SWEP.fakeHandLeft = Vector(13, -3, -5)

SWEP.Size = ITEM_SMALL

SWEP.TypeBrass = "12Gauge"

SWEP.IternalMagazine = true
SWEP.MaxAmmo = 6
SWEP.IsShotgun = true

function SWEP:PrimaryAttack()
    //self:DevShoot()
    self:ShootBullet()
end