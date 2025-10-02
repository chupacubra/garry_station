SWEP.Base = "gs_base_weapon" 

SWEP.PrintName = "GLOCK"

SWEP.Author			    = ""
SWEP.Contact			= "Epic smg"
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.Category = "Polar station: Guns"

SWEP.Primary.ClipSize       = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Sound          = "weapons/glock/glock18-1.wav"
SWEP.Primary.Cone           = 0.04
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.Automatic    = false

SWEP.m_bPlayPickupSound = false
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false 

SWEP.Name = "Glock"
SWEP.Desc = "gangster weapon"

SWEP.HoldType       = "revolver" 

SWEP.Recoil     = 1
SWEP.RecoilUp   = 5
SWEP.ShotSpeed  = 0.5
SWEP.ShotSpread = 0.5

SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"
SWEP.WModel = "models/weapons/w_pist_glock18.mdl"

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
    pos = vector_origin
}


SWEP.Spawnable = true

SWEP.addPos = Vector(10, -1.5, 0)
SWEP.addAng = Angle(0, 0, 0)
SWEP.sightPos = Vector(4.8, 5, -0.25)
SWEP.sightAng = Angle(0, 0, 0)
SWEP.fakeHandRight = Vector(3.5, -1.5, 2)

SWEP.Size = ITEM_SMALL

SWEP.TypeBrass = "9mm"

function SWEP:PrimaryAttack()
    //self:DevShoot()
    self:ShootBullet()
end