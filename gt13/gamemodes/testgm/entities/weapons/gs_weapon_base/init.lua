AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local function all_dmg(dmg)
    local ad = 0
    for _,v in pairs(dmg) do
        for _,vv in pairs(v) do
            ad = ad + vv
        end
    end
    return ad
end

function SWEP:Initialize()
    self:SetHoldType( self.HoldType )
    self.magazine = self.magazine or nil
    self:TriggerLoadWorldModel()
end

function SWEP:OnDrop()
    self:TriggerLoadWorldModel()
end

function SWEP:Deploy()
    self:SetHoldType(self.HoldType)
end

function SWEP:DealDamage(trace, dmgbullet)
    local dmgbul = all_dmg(dmgbullet)

    local force = trace.Normal * dmgbul * 10

    if trace.Entity:IsPlayer() then
        --player_manager.RunClass( trace.Entity,"HurtPart", trace.PhysicsBone, dmgbullet.BulletDamage)
        local target = FromHitGroupToPart(trace.HitGroup)
        hook.Run("GS_PlyTakeDamage",self:GetOwner(), trace.Entity, dmgbullet, target)
    else
        local dmg = DamageInfo()
        dmg:SetAttacker(self:GetOwner())
        dmg:SetDamage(dmgbul)
        dmg:SetDamageType(DMG_BULLET)
        dmg:SetDamageForce(force)

        trace.Entity:TakePhysicsDamage(dmg)
    end
end

function SWEP:MakeSingleShoot(dmgbullet)
    local bullet = {
        Damage = all_dmg(dmgbullet),
        Force = all_dmg(dmgbullet) * 2,
        TracerName = "Tracer",
        Src = self.Owner:GetShootPos(),
        Dir = self.Owner:GetAimVector(),
        Spread = Vector(self.spread, self.spread,0),
        Callback = function(ent, trace)
            self:DealDamage(trace, dmgbullet)
        end
    }

    self:FireBullets(bullet, false)
    self:CallOnClient("ShootGunEffect")
    self:ShootEffects()
    self:MakeRecoil()
end

function SWEP:PrimaryAttack()
 
end

function SWEP:SecondaryAttack()

end
--[[
function SWEP:BroadcastShootEffect(trace)
    net.Start("gs_weapon_base_effect")
    net.WriteEntity(trace.Entity)
    net.WriteVector(trace.HitPos)
    net.WriteVector(trace.StartPos)
    net.WriteInt(trace.SurfaceProps, 8)
    net.WriteInt(trace.HitBox, 8)
    net.Broadcast()
end
--]]

function SWEP:MakeRecoil()
    self:GetOwner():ViewPunch( Angle( -self.recoil, math.random(-1,1) * self.recoil, 0 ) )
end

function SWEP:GS_PickupWeapon(ply)
	if ply:HasWeapon( self:GetClass() ) or #ply:GetWeapons() == 4 then
		return false
	end
	ply:PickupWeapon( self, false )
end

function SWEP:StripMagazine()
    if self:GetOwner():GetActiveWeapon() != self then
        self:GetOwner():ChatPrint("You need to hold a gun in your hands")
        return false
    end

    if self.magazine == nil then
        self:GetOwner():ChatPrint("No magazine")
        return false
    end

    local trace = {
        start = self:GetOwner():EyePos(),
        endpos = self:GetOwner():EyePos() + self:GetOwner():GetAimVector() * 40  ,
        filter =  function( ent ) return ( ent != self:GetOwner() ) end
    }
    trace = util.TraceLine(trace)

    local magazine = duplicator.CreateEntityFromTable(game.GetWorld() , self.magazine)
    magazine:SetPos(trace.HitPos)
    magazine:Spawn()
    
    self.magazine = nil

    self:GetOwner():ChatPrint("You stripped magazine from "..self.Entity_Data.Name)
    self:ReloadGunEffect()
end

function SWEP:StripMagazineHand()
    if self:GetOwner():GetActiveWeapon() != self then
        self:GetOwner():ChatPrint("You need to hold a gun in your hands")
        return false
    end

    if self.magazine == nil then
        return false
    end

    local hand = self:GetOwner():GetWeapon( "gs_swep_hand" )
    local succes = hand:PutItemInHand(self.magazine)
    if succes then
        self.magazine = nil
        self:GetOwner():ChatPrint("You stripped magazine from "..self.Entity_Data.Name.." and put in hand")
        self:ReloadGunEffect()
    end
end

function SWEP:InsertMagazine(ent)
    if self:GetOwner():GetActiveWeapon() != self then
        self:GetOwner():ChatPrint("You need to hold a gun in your hands")
        return false
    end

    if self.magazine != nil then
        return false
    end

    if self.ammo_type != ent.Entity_Data.ENT_Name then
        return false
    end

    self.magazine = ent

    self:ReloadGunEffect()

    return nil
end

net.Receive("gs_ply_pickup_weapon",function(_, ply)
    local weap = net.ReadEntity()

    weap:GS_PickupWeapon(ply)
end)

net.Receive("gs_weapon_base_strip_magazine",function()
    local weap = net.ReadEntity()
    local hand = net.ReadBool()

    if hand then
        weap:StripMagazineHand()
    else
        weap:StripMagazine()
    end
end)


function SWEP:ReloadGunEffect()
    if self:GetOwner():GetActiveWeapon() != self then
        return
        --self:GetOwner():ChatPrint("You need to hold a gun in your hands")
    end
    self:SendWeaponAnim(ACT_VM_RELOAD)
    self:EmitSound(self.ReloadSound)
    self:GetOwner():SetAnimation(PLAYER_RELOAD)

    local reloadtime = self.Owner:GetViewModel():SequenceDuration() + 0.1

    self:SetNextPrimaryFire(CurTime() + reloadtime)
    timer.Simple(reloadtime, function()
        self:SetActivity(ACT_VM_IDLE)
    end)
end

function SWEP:TriggerLoadWorldModel()
    self:SetNWBool("magazine", self.magazine != nil)
end

