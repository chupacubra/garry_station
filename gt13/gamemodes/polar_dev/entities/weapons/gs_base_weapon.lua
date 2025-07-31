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

//SWEP.MuzzlePos      = Vector(50, -0.8, 20)
//SWEP.MuzzleAng      = Angle(-9.5, 0, 0)


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
SWEP.WorldModel = ""    // for fix muzle pos
SWEP.WModel = ""        //

SWEP.WorldModelCustom     = false
SWEP.WorldModelBonemerge  = true
SWEP.WorldModelBodyGroups = {}
SWEP.WorldModelOffsets    = {}

SWEP.Zoom = false
SWEP.SightPos = Vector()
SWEP.SightAng = Angle()

SWEP.HandOffsetVec = Vector(2,10, 0)
SWEP.HandOffsetAng = Angle(90, 0, 0)
SWEP.Recoil = 0.05

SWEP.addPos = Vector(0, 0, 0)
SWEP.addAng = Angle()

if SERVER then
    util.AddNetworkString("gs_swep_update_wm")
    util.AddNetworkString("gs_shoot")
    util.AddNetworkString("gs_wep_detach")
end

local defaultBulletPosAng = {
	default = {Vector(7.7, 0.4, 3.95), Angle(-3, 5.5, 0)},
	revolver = {Vector(7.7, 0.4, 3.95), Angle(-3, 5.5, 0)},
	ar2 = {Vector(20, -0.8, 11.2), Angle(-9.5, 0, 0)},
	smg = {Vector(14, -0.8, 6.8), Angle(-9.5, 0, 0)},
}

function SWEP:GetDefaultLocalMuzzlePos()
    local pos, ang

	pos, ang = unpack(defaultBulletPosAng[self:GetHoldType()] or defaultBulletPosAng.default)

	return pos, ang
end

function SWEP:GetDefaultMuzzlePos()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local att = owner:GetAttachment(owner:LookupAttachment('anim_attachment_rh'))
	if not att then return end
	local lpos, lang = self:GetDefaultLocalMuzzlePos()
	local pos, ang = LocalToWorld(lpos, lang, att.Pos, att.Ang)

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
    end

    //print(self.HoldType, holdtype)
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
        //self:UpdateWMState()
    end

    return true
end

function SWEP:Holster()
    if CLIENT then
        //self:UpdateWMState(true)
    end
    return true
end

function SWEP:Equip()
    self:UpdateHoldType()
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end
/*
    magazine contain only type of bullet
    contain only name of type bullet

    self.Magazine = {
        "9mm",
        "9mm",
        "9mm",
        "9mm_resin",
        ...
    }
*/

function SWEP:PopBulletFromMagazine()
    // return last bullet and remove from stack
    if !IsValid(self.Magazine) then
        return false
    end

    if #self.Magazine.Ammo < 1 then
        return false
    end

    local last = self.Magazine.Ammo[#self.Magazine.Ammo]

    local bullet = table.remove(self.Magazine.Ammo, last)

    return bullet
end

function SWEP:InsertMagazine(item)
    if CLIENT then return end

    if !item.IsWeaponMagazine then
        return false
    end

    if item.MagWeaponType != self:GetClass() then
        return false
    end

    if IsValid(self.Magazine) then
        // already have magazine
        return false
    end

    item:ItemHide()
    item:SetParentContainer(self)

    self.Magazine = item
    self:SetNWInt("MagAmmo", 30) 
    self:SetNWEntity("Magazine", self.Magazine)
    self:SetNextPrimaryFire(CurTime()+0.1)
    self:GetOwner():DoReloadEvent()

    self:UpdateWModelBodyGroups("mag")

end

function SWEP:EjectMag()
    if CLIENT then
        net.Start("gs_wep_detach")
        net.WriteEntity(self)
        net.SendToServer()
        return
    end
    if !IsValid(self.Magazine) then
        return false
    end

    local mag = self.Magazine

    local pos = self:GetOwner():GetPos() + Vector(0,0,40)

    mag:ItemRecover(pos)
    
    self.Magazine = nil
    self:SetNWInt("MagAmmo", 0)
    self:SetNWEntity("Magazine", nil)
    self:UpdateWModelBodyGroups("no_mag")
    self:GetOwner():DoReloadEvent()
end

function SWEP:InsertBullet(bullet)
    // shotguns, bolt action rifles have iternal mag (tube or smthng)
    if !self.AcceptCalibr[bullet] then 
        return false
    end

    if table.Count(self.Magazine.Ammo) + 1 > self.Magazine.MaxAmmo then
        return false
    end
    
    table.insert(self.Magazine.Ammo, bullet) 

    return true
end
 
function SWEP:ItemInteraction(item)
    return self:InsertMagazine(item)
end

function SWEP:InitializeWM()
    //print("Init cl wm", self, self.WorldModelCustom)
    if !self.WorldModelCustom then return end

    self.WMGun = ClientsideModel(self.WModel)

    //self:UpdateWMState()

    if self.WorldModelBodyGroups["base"] then
        self:ChangeBodyGroup("base")
    end
    
end

function SWEP:ChangeBodyGroup(bodygroups_set)
    if SERVER then return end
    local gun = self.WMGun
    print("CHANGE BG ", bodygroups_set)

    if !IsValid(gun) then return end
    if type(bodygroups_set) == "string" then
        bodygroups_set = self.WorldModelBodyGroups[bodygroups_set]
    end
    if !bodygroups_set then return end

    local bodygroups_data = gun:GetBodyGroups()
    if #bodygroups_data == 0 then return end
    

    if type(bodygroups_set) == "string" then
        gun:SetBodyGroups(bodygroups_set)
        return
    end

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

function SWEP:UpdateWMState(holster)
end

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    local gun = self.WMGun

    if (IsValid(ply)) then
        local offsetVec = self.WorldModelOffsets.pos
        local offsetAng = self.WorldModelOffsets.ang
        
        local boneid = ply:LookupBone("ValveBiped.Bip01_R_Hand")
        if !boneid then return end

        local matrix = ply:GetBoneMatrix(boneid)
        if !matrix then return end

        local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

        gun:SetRenderOrigin(newPos)
        gun:SetRenderAngles(newAng)

        gun:SetupBones()
	    gun:DrawModel()
    else
        gun:SetRenderOrigin(self:GetPos())
        gun:SetRenderAngles(self:GetAngles())
	    gun:DrawModel()
    end

end

function SWEP:GetContextButtons()
    local buttons = table.Copy(self.ContextCallback or {})

    if IsValid(self:GetNWEntity("Magazine")) then
        buttons["detach_mag"] = {
            name = "Detach Mag",
            func = function()
                self:EjectMag()
            end,
            icon = "icon16/arrow_down.png",
        }
    end

    /*
    elseif self.Magazine.IsIternal then
        buttons["pop_bullet"] = {
        name = "Get bullet", -- ?
        func = function()
            local bullet = self:PopUpBulletFromMagazine()
            -- RecoverBullet(self, bullet)
        end,
        icon = "icon16/arrow_up.png",
        }
    end
    */
    return buttons
end

function SWEP:OnRemove()
    if self:GetOwner() then hook.Run("PlayerDroppedWeapon", self:GetOwner(), self) end
    if IsValid(self.WMGun) then self.WMGun:Remove() end
end

function SWEP:DevShoot()
    if not IsValid(self) then return nil end

	if self:GetOwner():IsPlayer() then
		self:GetOwner():LagCompensation(true)
	end

	local shootOrigin, shootAngles = self:GetBulletSourcePos()
    local shootDir = shootAngles:Forward()

    if SERVER then
        debugoverlay.Axis(shootOrigin, shootAngles, 5, 1, true)
    else
        debugoverlay.Axis(shootOrigin, shootAngles, 5, 1, true)
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
	bullet.Damage = 50 //dmg or 25
	bullet.Attacker = ply
    bullet.Callback = function(att, trace, dmg)
        //self:BulletCallbackFunc()
    end
	self:FireBullets(bullet)

	if self:GetOwner():IsPlayer() then
		self:GetOwner():LagCompensation(false)
	end

    if CLIENT then
        local ef = EffectData()
		ef:SetEntity(self.WMGun)
		ef:SetAttachment(self.WMGun:LookupAttachment( "muzzle" ))
		ef:SetFlags(1)
		util.Effect("MuzzleFlash", ef)
    end

    self:SetNWFloat("VisualRecoil", self:GetNWFloat("VisualRecoil") + self.Recoil)
end

function SWEP:ShootBullet()
    if not IsValid(self) then return nil end
    
    local ammo = self:GetNWInt("MagAmmo")
    
    if ammo < 1 then 
        self:EmitSound("Weapon_AR2.Empty")
        self:SetNextPrimaryFire(CurTime()+1)
        return
    end
	if self:GetOwner():IsPlayer() then
		self:GetOwner():LagCompensation(true)
	end

	local shootOrigin, shootAngles = self:GetBulletSourcePos()
    local shootDir = shootAngles:Forward()

    if SERVER then
        debugoverlay.Axis(shootOrigin, shootAngles, 5, 1, true)
    else
        debugoverlay.Axis(shootOrigin, shootAngles, 5, 1, true)
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
	bullet.Damage = 50 //dmg or 25
	bullet.Attacker = ply
    bullet.Callback = function(att, trace, dmg)
        //self:BulletCallbackFunc()
    end
	self:FireBullets(bullet)

	if self:GetOwner():IsPlayer() then
		self:GetOwner():LagCompensation(false)
	end

    if CLIENT then
        local ef = EffectData()
		ef:SetEntity(self.WMGun)
		ef:SetAttachment(self.WMGun:LookupAttachment( "muzzle" ))
		ef:SetFlags(1)
		util.Effect("MuzzleFlash", ef)
    end
    self:EmitSound(self.Primary.Sound)
    self:SetNWInt("MagAmmo", ammo - 1)
    self:SetNWFloat("VisualRecoil", self:GetNWFloat("VisualRecoil") + self.Recoil)
    self:SetNextPrimaryFire(CurTime()+0.1)
end

function SWEP:IsLocal()
	return CLIENT and self:GetOwner() == LocalPlayer()
end

// this from homigrad weapons
function SWEP:Step()
	self.animProg = self:GetNWFloat("VisualRecoil") or 0
	self.animLerp = self.animLerp or Angle(0, 0, 0)
	self.animLerp = LerpAngle(0.25, self.animLerp, Angle(5, 0, self.HoldType == "revolver" and 0 or -2) * self.animProg)
	local ply = self:GetOwner()
	if self:GetNWFloat("VisualRecoil") > 0 then
		if self.HoldType ~= "revolver" then
			ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Clavicle"), Vector(0, -self.animLerp.x / 3, -self.animLerp.x / 3), false)
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Clavicle"), Angle(0, 0, -self.animLerp.x), false)
		end

		ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Hand"), self.animLerp * 2, false)
		self:SetNWFloat("VisualRecoil", Lerp(4 * FrameTime(), self:GetNWFloat("VisualRecoil") or 0, 0))
	end

	if SERVER then
		ply:SetNWInt("RightArm", ply.RightArm)
		ply:SetNWInt("LeftArm", ply.LeftArm)
	end

	local isLocal = self:IsLocal()
	if isLocal then
		self.eyeSpray = self.eyeSpray or Angle(0, 0, 0)
		ply:SetEyeAngles(ply:EyeAngles() + self.eyeSpray)
		self.eyeSpray = LerpAngleFT(0.5, self.eyeSpray, Angle(0, 0, 0))
		local p = 0.005
		self.eyeSpray = self.eyeSpray + Angle(math.Rand(-p, p), math.Rand(-p, p), 0)
	end

	if isLocal then
		if ply:GetNWInt("LeftArm") < 1 or ply:GetNWInt("RightArm") < 1 then
			local p = 0.1
			self.eyeSpray = self.eyeSpray + Angle(math.Rand(-p, p), math.Rand(-p, p), 0)
		end
	end
end

// необходимо описать синхронизацию магазина
// можно реализовать это через NW, так как за время перезарядки NW успеет скинуться

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) or (owner:IsPlayer() and not owner:Alive()) or owner:GetActiveWeapon() ~= self then return end --wtf i dont know
    if self.Step then
        self:Step()
    end

    self.Zoom = owner:KeyDown(IN_ATTACK2)
    
    self:UpdateHoldType()
    //self:SetNWInt("AmmoMag", #self.Magazine.Ammo)
end

net.Receive("gs_swep_update_wm", function(_, ply)
    local self = net.ReadEntity()
    local set  = net.ReadString()

    self:ChangeBodyGroup(set)
end)

net.Receive("gs_wep_detach", function(_, ply)
    local ent = net.ReadEntity()

    ent:EjectMag()
    // rwgkmrgu
    //if !IsValid(self)
end)