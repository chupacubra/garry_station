SWEP.Author			    = "Devil right hand"
SWEP.Contact			= "Poeli"
SWEP.Purpose			= "KILL!"
SWEP.Instructions		= "KILL!"

SWEP.Primary.ClipSize       = -1
SWEP.Primary.Automatic      = false
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.Automatic    = false

SWEP.UseHands           = true
SWEP.m_bPlayPickupSound = false
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false 

SWEP.Name = "Boomstick"
SWEP.Desc = "Palka-ubivalka"

SWEP.SoundShot   = ""
SWEP.SoundReload = ""
SWEP.Silenced    = false

SWEP.MuzzlePos      = Vector(50, -0.8, 20)
SWEP.MuzzleAng      = Angle(-9.5, 0, 0)


SWEP.ShellPos       = nil

SWEP.HoldType       = "pistol"  // basic holdtype

SWEP.Recoil     = 10
SWEP.RecoilUp   = 15
SWEP.ShotSpeed  = 0.5
SWEP.ShotSpread = 0.5

SWEP.LastBullet = nil
SWEP.Active     = false
SWEP.Use2Hand   = false

SWEP.GMSWEP = true

SWEP.ViewModel  = ""
SWEP.WorldModel = ""

SWEP.WorldModelCustom     = false
SWEP.WorldModelBonemerge  = true
SWEP.WorldModelBodyGroups = {}
SWEP.WorldModelOffsets    = {}

SWEP.Zoom = false
SWEP.SightPos = Vector()
SWEP.SightAng = Angle()

SWEP.HandOffsetVec = Vector(2,10, 0)
SWEP.HandOffsetAng = Angle(90, 0, 0)



//SWEP.addPos = Vector(0,0,100)
//SWEP.addAng = Angle()

if SERVER then
    util.AddNetworkString("gs_swep_update_wm")
end

local defaultBulletPosAng = {
	default = {Vector(7.7, 0.4, 3.95), Angle(-3, 5.5, 0)},
	revolver = {Vector(7.7, 0.4, 3.95), Angle(-3, 5.5, 0)},
	ar2 = {Vector(20, -0.8, 11.2), Angle(-9.5, 0, 0)},
	smg = {Vector(14, -0.8, 6.8), Angle(-9.5, 0, 0)},
}

function SWEP:GetDefaultLocalMuzzlePos()
    local pos, ang
    if self.MuzzlePos and self.MuzzleAng then
        pos, ang = self.MuzzlePos, self.MuzzleAng
    else
	    pos, ang = unpack(defaultBulletPosAng[self:GetHoldType()] or defaultBulletPosAng.default)
    end
	return pos, ang
end

function SWEP:GetDefaultMuzzlePos()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local att = owner:GetAttachment(owner:LookupAttachment('anim_attachment_rh'))
	if not att then return end
	local lpos, lang = self:GetDefaultLocalMuzzlePos()
	local pos, ang = LocalToWorld(lpos, lang, att.Pos, att.Ang)
    //print("1213")
	return pos, ang
end

function SWEP:GetBulletSourcePos()
	if self.addPos or self.addAng then
		local owner = self:GetOwner()
		if not IsValid(owner) then return end
		local att = owner:GetAttachment(owner:LookupAttachment('anim_attachment_rh'))
		if att then
			local defaultlpos, defaultlang = self:GetDefaultLocalMuzzlePos()
			local pos, ang = LocalToWorld(self.addPos or defaultlpos, self.addAng or defaultlang or angle_zero, att.Pos, att.Ang)

			return pos, ang
		end

    end

	local pos, ang = self:GetDefaultMuzzlePos()


	return pos, ang
end

function SWEP:BulletCallbackFunc(dmgAmt, ply, tr, dmg, tracer, hard, multi)
	if tr.MatType == MAT_FLESH then
		util.Decal("Blood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		local vPoint = tr.HitPos
		local effectdata = EffectData()
		effectdata:SetOrigin(vPoint)
		util.Effect("BloodImpact", effectdata)
	end

	if tr.HitSky then return end
	if hard then

	end
end


function SWEP:UpdateHoldType()
    local holdtype = self.HoldType

    if holdtype == "pistol" then
        if self.Zoom then holdtype = "revolver" end
    elseif holdtype == "shotgun" then
        if self.Zoom then holdtype = "ar2" end
    elseif holdtype == "ar2" or holdtype == "smg" then
        //if self.Zoom then holdtype = "rpg" end
    end

    print(self.HoldType, holdtype)
    self:SetHoldType(holdtype)
end

function SWEP:UpdateWModelBodyGroups(toset)
    if SERVER then
        net.Start("gs_swep_update_wm")
        net.WriteEntity(self)
        net.WriteString(toset)
        net.Broadcast()
    else
        self:ChangeBodyGroup(toset)
    end
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    if CLIENT then
        self:InitializeWM()
    end
end

function SWEP:Deploy()
    self:UpdateHoldType()
    if CLIENT then
        self:UpdateWMState()
    end

    return true
end

function SWEP:Holster()
    if CLIENT then
        self:UpdateWMState(true)
    end
    return true
end

function SWEP:Equip()
    self:UpdateHoldType()
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
    self.Zoom = !self.Zoom
    self:UpdateHoldType()
    if CLIENT then
        self:ChangeBodyGroup("base2")
    end
end

function SWEP:InitializeWM()
    print("Init cl wm", self, self.WorldModelCustom)
    if !self.WorldModelCustom then return end

    self.WMGun = ClientsideModel(self.WorldModel)

    self:UpdateWMState()

    if self.WorldModelBodyGroups["base"] then
        self:ChangeBodyGroup("base")
    end
end

function SWEP:ChangeBodyGroup(bodygroups_set)
    if SERVER then return end
    local gun = self.WMGun
    if !IsValid(gun) then return end
    if type(bodygroups_set) == "string" then
        bodygroups_set = self.WorldModelBodyGroups[bodygroups_set]
    end
    if !bodygroups_set then return end

    local bodygroups_data = gun:GetBodyGroups()
    if #bodygroups_data == 0 then return end
    
    for name_id, name_subid in pairs(bodygroups_set) do
        local bg_id = name_id
        if type(name_id) == "string" then
            bg_id = gun:FindBodygroupByName(name_id)
        end
        
        if bg_id == nil or bg_id == -1 then continue end
        local bg_subid = name_id
        
        if type(name_id) == "number" then 
            gun:SetBodygroup(bg_id, bg_subid)
        else
            for subid, subname in pairs(bodygroups_data[bg_id+1].submodels) do
                if subname == name_subid then
                    
                    gun:SetBodygroup(bg_id, subid)
                end
            end
        end
    end
end
/*
function SWEP:DrawWorldModel()
    if !self.WorldModelCustom then self:DrawModel() end
end
*/
function SWEP:UpdateWMState(holster)
    /*
    print("Update wm state",self.WMGun, holster)
    local gun = self.WMGun
    
    if !IsValid(gun) then 
        return
    end
    local owner = self:GetOwner()
    if owner then
        if !holster then
            gun:SetNoDraw(false)
        else
            // the drawing of wep in another hand in plyhanddraw
        end
    else
        gun:SetParent(self)
        gun:SetNoDraw(false)
    end
    */
end

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    //local _Owner = self:GetOwner()

    local gun = self.WMGun

    if (IsValid(ply)) then
        -- Specify a good position
        local offsetVec = self.WorldModelOffsets.pos
        local offsetAng = self.WorldModelOffsets.ang
        
        local boneid = ply:LookupBone("ValveBiped.Bip01_R_Hand") -- Right Hand
        if !boneid then return end

        local matrix = ply:GetBoneMatrix(boneid)
        if !matrix then return end

        local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

        gun:SetRenderOrigin(newPos)
        gun:SetRenderAngles(newAng)

        gun:SetupBones()
	    gun:DrawModel()
        //print("123")
    else
        //self:SetPos(self:GetPos())
        gun:SetRenderOrigin(self:GetPos())
        gun:SetRenderAngles(self:GetAngles())
	    gun:DrawModel()
    end

end

function SWEP:OnRemove()
    if self:GetOwner() then hook.Run("PlayerDroppedWeapon", self:GetOwner(), self) end
    if IsValid(self.WMGun) then self.WMGun:Remove() end
end
/*
function SWEP:MuzzleFlash()
    local pos, ang = self:GetBulletSourcePos()

    local effect = EffectData()
    effect:SetOrigin(pos)
    effect:SetAngles(ang)
    effect:SetScale(1)
    util.Effect("MuzzleEffect", effect)
end
*/
function SWEP:DevShoot()
    if not IsValid(self) then return nil end

	if self:GetOwner():IsPlayer() then
		self:GetOwner():LagCompensation(true)
	end

	local shootOrigin, shootAngles = self:GetBulletSourcePos()
    //print(shootOrigin, shootAngles)
    local shootDir = shootAngles:Forward()
    if SERVER then
        debugoverlay.Cross(shootOrigin, 5, 1, Color(255,0,0), true)
    else
        debugoverlay.Cross(shootOrigin, 5, 1, Color(34,0,255), true)

    end
    debugoverlay.Line(shootOrigin, shootOrigin + shootDir*1000,1,nil, true)

	local ply = self:GetOwner()
	local bullet = {}
	local cone = self.Primary.Cone
	bullet.Num = self.NumBullet or 1
	bullet.Src = shootOrigin
	bullet.Dir = shootDir
	bullet.Spread = Vector(cone, cone, 0)
	bullet.Tracer = 1
	bullet.TracerName = 4
	bullet.Force = 100 / 20
	bullet.Damage = 50//dmg or 25
	//bullet.AmmoType = self.Primary.Ammo
	bullet.Attacker = ply

	self:FireBullets(bullet)

	if self:GetOwner():IsPlayer() then
		self:GetOwner():LagCompensation(false)
	end

    if CLIENT then
        PrintTable(self.WMGun:GetAttachments())
    end

    local ef = EffectData()
    ef:SetEntity(self.WMGun)
    ef:SetAttachment(1) -- self:LookupAttachment( "muzzle" )
    ef:SetFlags(1) -- Sets the Combine AR2 Muzzle flash
    ef:SetOrigin(shootOrigin)
    ef:SetAngles(shootAngles)
    ef:SetScale(1)
    util.Effect("CS_MuzzleFlash_X", ef)
    //util.Effect("CS_MuzzleFlash_X", effect)

    //self:GetOwner():MuzzleFlash()
    //self:MuzzleFlash()
    //self:ShootEffects()
    //self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    //print("123")
    ply:SetAnimation(PLAYER_ATTACK1)
end

net.Receive("gs_swep_update_wm", function(_, ply)
    local self = net.ReadEntity()
    local set  = net.ReadString()

    self:ChangeBodyGroup(set)
end)


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