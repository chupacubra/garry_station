SWEP.Base = "gs_base_weapon" 

SWEP.Author			    = "TEST WEAPON 3"
SWEP.Contact			= "TEST3"
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.Primary.ClipSize       = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Sound = "weapons/galil/galil-1.wav"
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.Automatic    = false

SWEP.UseHands           = true
SWEP.m_bPlayPickupSound = false
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false 

SWEP.Name = "SDKFZ-31"
SWEP.Desc = "Palka-ubivalka"

SWEP.HoldType       = "ar2"  // basic holdtype

SWEP.Recoil     = 10
SWEP.RecoilUp   = 15
SWEP.ShotSpeed  = 0.5
SWEP.ShotSpread = 0.5

SWEP.WorldModel = "models/kali/weapons/mgsv/am type 69 rifle.mdl"

SWEP.WorldModelCustom     = true
SWEP.WorldModelBonemerge  = true
SWEP.WorldModelBodyGroups = {}

SWEP.WorldModelOffsets    = {
    pos = Vector(7,-1,3),
    ang = Angle(10,0,180)
}

SWEP.Spawnable = true

SWEP.addPos = Vector(50, -1.5, 10)
SWEP.addAng = Angle(-9.5, -0.1, 0)
SWEP.sightPos = Vector(5.1, 5, 0.7)
SWEP.sightAng = Angle(-0, -2.5, 0)

SWEP.MuzzlePos      = Vector(50, 0, 20)
SWEP.MuzzleAng      = Angle(-9.5, 0, 0)

SWEP.fakeHandRight = Vector(12, -2, 0)
SWEP.fakeHandLeft = Vector(13, -3, -5)

function SWEP:PrimaryAttack()
    self:DevShoot()
    self:SetNextPrimaryFire(CurTime()+0.1)
    self:EmitSound(self.Primary.Sound)
    self:MuzzleFlash()
    self:ShootEffects()
    local ef = EffectData()
		ef:SetEntity(self.WMGun)
		ef:SetAttachment(2) -- self:LookupAttachment( "muzzle" )
		ef:SetFlags(1) -- Sets the Combine AR2 Muzzle flash
		util.Effect("CS_MuzzleFlash", ef)
    
end
