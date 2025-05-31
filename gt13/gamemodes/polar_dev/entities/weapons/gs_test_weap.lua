SWEP.Base = "gs_base_weapon" 

SWEP.Author			    = "TEST WEAPON"
SWEP.Contact			= "TEST"
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.Primary.ClipSize       = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Sound = "weapons/p90/p90-1.wav"
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.Automatic    = false

SWEP.UseHands           = true
SWEP.m_bPlayPickupSound = false
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false 

SWEP.Name = "Skibidiweapon"
SWEP.Desc = "Palka-ubivalka"

SWEP.HoldType       = "pistol"  // basic holdtype

SWEP.Recoil     = 10
SWEP.RecoilUp   = 15
SWEP.ShotSpeed  = 0.5
SWEP.ShotSpread = 0.5

SWEP.WorldModel = "models/kali/weapons/black_ops/pm-63 rak.mdl"

SWEP.WorldModelCustom     = true
SWEP.WorldModelBonemerge  = true
SWEP.WorldModelBodyGroups = {
    ["base"] = {
        ["Foregrip"]    = "Foregrip_DN",
        ["Stock"]       = "Stock_Unfolded",
    },
    ["base2"] = {
        ["Foregrip"]    = "Foregrip_DN",
        ["Stock"]       = "Stock_Unfolded",
    }
}
SWEP.WorldModelOffsets    = {
    pos = Vector(4,-1.5,-3),
    ang = Angle(0,85,185)
}
SWEP.Spawnable = true

SWEP.addPos = Vector(5, 0.1, 4)
SWEP.addAng = Angle(-2.5, 5.05, 0)
SWEP.sightPos = Vector(4.2, 11, 1.3) --Vector(3.7, 15, 1.55)
SWEP.sightAng = Angle(4, 8, 0)
SWEP.fakeHandRight = Vector(3.5, -1.5, 2)

function SWEP:PrimaryAttack()
    self:DevShoot()
    self:SetNextPrimaryFire(CurTime()+0.1)
    self:EmitSound(self.Primary.Sound)
end

