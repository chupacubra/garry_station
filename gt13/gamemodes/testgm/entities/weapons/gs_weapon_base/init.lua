AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function SWEP:Initialize()
    self:SetHoldType( "pistol" )
end

function SWEP:DecreaseAmmo() 

end

function SWEP:IncreaseAmmo()

end 

function SWEP:GetAmmo()

end

function SWEP:SetTypeAmmo(atype)
    self.ammo_type = atype
end

function SWEP:ReloadAmmo()
    --[[find in invSWEPory player for some ammo]]
end

function SWEP:CountAmmo()
    return self.ammo_magazine
end

function SWEP:DealDamage(trace, damage, dtype )
    if trace.Entity:IsPlayer() then
        player_manager.RunClass( trace.Entity,"HurtPart", trace.PhysicsBone, damage, dtype)
    end
end

function SWEP:MakeSingleShoot()
    local bullet = {
        Damage = 0,
        Force = 5,
        TracerName = "Tracer",
        Src = self.Owner:GetShootPos(),
        Dir = self.Owner:GetAimVector(),
        Spread = Vector(self.spread, self.spread,0),
        Callback = function(ent, trace)
            self:BroadcastShootEffect(trace)
            print(self.damage_type)
            self:DealDamage(trace, self.damage, self.damage_type)
        end
    }

    local s = self.Owner:FireBullets( bullet )
    self:ShootEffects()
    self:MakeRecoil()
end

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end

function SWEP:BroadcastShootEffect(trace)
    --Entity, Origin, Start, SurfaceProp, DamageType, HitBox
    net.Start("gs_weapon_base_effect")
    net.WriteEntity(trace.Entity)
    net.WriteVector(trace.HitPos)
    net.WriteVector(trace.StartPos)
    net.WriteInt(trace.SurfaceProps, 8)
    --damagetype on client
    net.WriteInt(trace.HitBox, 8)
    net.Broadcast()
end

function SWEP:MakeRecoil()
    self:GetOwner():ViewPunch( Angle( -self.recoil, 0, 0 ) )
end

function SWEP:GS_PickupWeapon(ply)
	if ply:HasWeapon( self:GetClass() ) or #ply:GetWeapons() == 4 then
		return false
	end
	ply:PickupWeapon( self, false )
end

net.Receive("gs_ply_pickup_weapon",function()
    local weap = net.ReadEntity()
    local ply  = net.ReadEntity()

    weap:GS_PickupWeapon(ply)
end)