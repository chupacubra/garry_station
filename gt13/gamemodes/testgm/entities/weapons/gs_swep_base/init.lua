AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

--[[
    self.magazine_size = 9
    self.ammo_type = GS_AMMO_PISTOL
    self.max_damage = 15,
    self.min_damage = 8,
]]

--[[
function SWEP:CanPrimaryAttack()

	if ( self.Weapon:Clip1() <= 0 ) then
	
		self:EmitSound( "Weapon_Pistol.Empty" )
		self:SetNextPrimaryFire( CurTime() + 0.2 )
		self:Reload()
		return false
		
	end

	return true

end
--]]

function ENT:DecreaseAmmo()

end

function ENT:IncreaseAmmo()

end

function ENT:GetAmmo()

end

function ENT:SetTypeAmmo(atype)
    self.ammo_type = atype
end

function ENT:ReloadAmmo()

end

function ENT:CountAmmo()

end

function ENT:DealDamage()

end

function ENT:MakeSingleShoot()

end
