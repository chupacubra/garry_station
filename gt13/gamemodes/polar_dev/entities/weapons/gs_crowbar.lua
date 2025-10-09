SWEP.Base = "gs_base_swep"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category           = "GS"
SWEP.SlotPos            = 1

SWEP.WorldModel = "models/weapons/w_crowbar.mdl" // crowbar
SWEP.HoldType = "melee2"

SWEP.GMSWEP = true

SWEP.Primary.Automatic = true
SWEP.PrimarySound = "Weapon_Crowbar"
SWEP.PrimaryDelay = 0.5

SWEP.WorldModelCustom     = false
SWEP.WorldModelBonemerge  = true
SWEP.WorldModelBodyGroups = {}
SWEP.WorldModelOffsets    = {}

SWEP.MinDMG = 5
SWEP.MaxDMG = 15
SWEP.HitForce = 200
SWEP.CritRand = 0.7

function SWEP:Secondary()
end

function SWEP:DoImpactEffect( tr, nDamageType )

	if ( tr.HitSky ) then return end
	
	local effectdata = EffectData()
    effectdata:SetEntity(tr.Entity)
    effectdata:SetStart(self:GetOwner():GetShootPos())
	effectdata:SetOrigin( tr.HitPos  )
	effectdata:SetNormal( tr.HitNormal )
    effectdata:SetDamageType(nDamageType)
    effectdata:SetHitBox(tr.HitBox)
    effectdata:SetSurfaceProp(tr.SurfaceProps)

	util.Effect( "Impact", effectdata )

end

function SWEP:Primary()
    // attack
    local owner = self:GetOwner()

    self:EmitSound( "Weapon_Crowbar.Swing" )
    owner:SetAnimation( PLAYER_ATTACK1 )


    local tracedata = {}
	tracedata.start = owner:GetShootPos()
	tracedata.endpos = owner:GetShootPos() + owner:GetAimVector() * 75
	tracedata.filter = owner
	tracedata.mins =  Vector( -8 , -8 , -8 )
	tracedata.maxs =  Vector( 8 , 8 , 8 )
	
	-- It is recommended to use an IsPlayer check in case the weapon is being used by an NPC.
	timer.Simple(0.1, function()
        //if ( owner:IsPlayer() ) then
            owner:LagCompensation( true )
        //end
        
        local trace = util.TraceHull( tracedata )
        
        //if ( owner:IsPlayer() ) then
            owner:LagCompensation( false )
        //end
        
        if trace.Hit then
            // do imp
            self:DoImpactEffect( trace, DMG_CLUB )
            
            local ent = trace.Entity
            if !IsValid(ent) then return end

            local part = HitGroupPart[trace.HitGroup]
            local dmg = DamageInfo()

            dmg:SetAttacker(self:GetOwner())
            dmg:SetInflictor(self)
            dmg:SetDamageType(DMG_CLUB)

            if math.random() < self.CritRand then // CRIT!
                dmg:SetDamage( math.random(self.MinDMG*2, self.MaxDMG*2) )
            else
                dmg:SetDamage( math.random(self.MinDMG, self.MaxDMG) ) 
            end


            if ent:IsPlayer() then
                ent:SetLastHitGroup(trace.HitGroup)
            end

            if ent.TakeDamageInfo then
                ent:TakeDamageInfo(dmg)
            end
            
            if CLIENT then return end

            if ent:IsPlayer() or ent:IsNPC() then
                ent:SetVelocity(trace.Normal * self.HitForce, trace.HitPos)
            else
                ent:GetPhysicsObject():AddVelocity(trace.Normal * self.HitForce)
            end
            
        end
    end)
	self:SetNextPrimaryFire( CurTime() + 0.5 )
end