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

SWEP.Name = "Skibidiweapondfdf"
SWEP.Desc = "Palka-ubivalkdfdfdfdfa"

SWEP.HoldType       = "ar2"  // basic holdtype

SWEP.Recoil     = 10
SWEP.RecoilUp   = 15
SWEP.ShotSpeed  = 0.5
SWEP.ShotSpread = 0.5

SWEP.WorldModel = "models/kali/weapons/mgsv/am type 69 rifle.mdl"

SWEP.WorldModelCustom     = true
SWEP.WorldModelBonemerge  = true
SWEP.WorldModelBodyGroups = {
    //["base"] = {
    //    ["Foregrip"]    = "Foregrip_DN",
    //    ["Stock"]       = "Stock_Unfolded",
    //},
    //["base2"] = {
    //    ["Foregrip"]    = "Foregrip_DN",
    //    ["Stock"]       = "Stock_Unfolded",
    //}
}
SWEP.WorldModelOffsets    = {
    pos = Vector(7,-1,3),
    ang = Angle(10,0,180)
}

SWEP.Spawnable = true
--[[
SWEP.addPos = Vector(5, 0.1, 4)
SWEP.addAng = Angle(-2.5, 5.05, 0)
SWEP.sightPos = Vector(4.2, 11, 1.3) --Vector(3.7, 15, 1.55)
SWEP.sightAng = Angle(4, 8, 0)
SWEP.fakeHandRight = Vector(3.5, -1.5, 2)
--]]

SWEP.addPos = Vector(10, -1.05, 5)
SWEP.addAng = Angle(-9.5, -0.1, 0)
SWEP.sightPos = Vector(5.1, 5, 0.7)
SWEP.sightAng = Angle(-0, -2.5, 0)

SWEP.fakeHandRight = Vector(12, -2, 0)
SWEP.fakeHandLeft = Vector(13, -3, -5)

function SWEP:PrimaryAttack()
    self:DevShoot()
    self:SetNextPrimaryFire(CurTime()+0.1)
    self:EmitSound(self.Primary.Sound)
end

local vecZero = vector_origin
local angZero = angle_zero
local hg_show_hitposmuzzle = CreateClientConVar("hg_show_hitposmuzzle", 0, false, false, "Shows debug weapon hitpos", 0, 2)
local x = Vector(1, 0.025, 0.025)
hook.Add(
	"HUDPaint",
	"admin_hitpos",
	function()
		if hg_show_hitposmuzzle:GetInt() <= 0 then return end
		if not LocalPlayer():IsAdmin() then return end
		local wep = LocalPlayer():GetActiveWeapon()
		if not IsValid(wep) or wep.Base ~= "salat_base" then return end
		local att = wep:LookupAttachment("muzzle")
		if not att then return end
		local att = wep:GetAttachment(att)
		if not att then return end
		local shootOrigin, shootAngles = wep:GetBulletSourcePos()
		local tr = util.QuickTrace(shootOrigin, shootAngles:Forward() * 1000, LocalPlayer())
		local hit = tr.HitPos:ToScreen()
		surface.SetDrawColor(color_white)
		surface.DrawRect(hit.x - 2.5, hit.y - 2.5, 5, 5)
	end
)

hook.Add(
	"PostDrawTranslucentRenderables",
	"Boxxie",
	function()
		if hg_show_hitposmuzzle:GetInt() <= 1 then return end
		if not LocalPlayer():IsAdmin() then return end
		local wep = LocalPlayer():GetActiveWeapon()
		if not IsValid(wep) or wep.Base ~= "salat_base" then return end
		local att = wep:LookupAttachment("muzzle")
		if not att then return end
		local att = wep:GetAttachment(att)
		if not att then return end
		local shootOrigin, shootAngles = wep:GetBulletSourcePos()
		render.SetColorMaterial() -- white material for easy coloring
		cam.IgnoreZ(true) -- makes next draw calls ignore depth and draw on top
		render.DrawBox(shootOrigin, shootAngles, x, -x, color_white) -- draws the box 
		cam.IgnoreZ(false) -- disables previous call
	end
)