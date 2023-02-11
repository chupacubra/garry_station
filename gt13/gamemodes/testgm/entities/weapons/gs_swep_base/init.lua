AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
-- for viewmodel

local anim_list = {
	deploy = 0,
	idle   = 1,
	swing1 = 2,
	swing2 = 3,
	hit1   = 4,
	hit2   = 5,
	hit3   = 6,
	hit4   = 7,
	undeploy = 8,
}

function SWEP:SoundHit(hit)
    if hit then
        self:GetOwner():EmitSound(Sound(self.PrimarySound..".Melee_HitWorld"))
    else
        self:GetOwner():EmitSound(Sound(self.PrimarySound..".Single"))
    end
end

function SWEP:Hit(trace)
    if trace.Enity:IsPlayer() then
        print("hit padlu")
    else

    end
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:MakeTrace()
	local tracedata = {}
	tracedata.start = self:GetOwner():GetShootPos()
	tracedata.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 75
	tracedata.filter = self:GetOwner()
	tracedata.mins =  Vector( -8 , -8 , -8 )
	tracedata.maxs =  Vector( 8 , 8 , 8 )
	
	if ( self:GetOwner():IsPlayer() ) then
		self:GetOwner():LagCompensation( true )
	end
	
	local tr = util.TraceHull( tracedata )
	
	if ( self:GetOwner():IsPlayer() ) then
		self:GetOwner():LagCompensation( false )
	end
	
	return tr
end

function SWEP:SwingAnim(hit)
	local VModel = self:GetOwner():GetViewModel()
	local anim

	if hit then
		anim = "hit".. math.random(1, 4)
	else
		anim =  "swing".. math.random(1, 2)
	end
	


	VModel:SendViewModelMatchingSequence(anim_list[anim])
end

function SWEP:Deploy()
	self:SetHoldType(self.HoldType)
end

function SWEP:Holster()
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

function SWEP:GS_PickupWeapon(ply)
	if ply:HasWeapon( self:GetClass() ) or #ply:GetWeapons() == 4 then
		return false
	end
	ply:PickupWeapon( self, false )
end
