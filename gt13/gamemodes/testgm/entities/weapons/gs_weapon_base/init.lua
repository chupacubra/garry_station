AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function SWEP:Initialize()
    self:SetHoldType( self.HoldType )
    self.magazine = self.magazine or nil
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:TriggerLoadWorldModel(self.magazine != nil)
        end
    end)
end

function SWEP:OnDrop()
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:TriggerLoadWorldModel(self.magazine != nil)
        end
    end)
end

function SWEP:Deploy()
    self:SetHoldType(self.HoldType)
end

function SWEP:DealDamage(trace, dmgbullet )
    if trace.Entity:IsPlayer() then
        player_manager.RunClass( trace.Entity,"HurtPart", trace.PhysicsBone, dmgbullet.BulletDamage)
    end
end

function SWEP:MakeSingleShoot(dmgbullet)
    local bullet = {
        Damage = 0,
        Force = 5,
        TracerName = "Tracer",
        Src = self.Owner:GetShootPos(),
        Dir = self.Owner:GetAimVector(),
        Spread = Vector(self.spread, self.spread,0),
        Callback = function(ent, trace)
            self:BroadcastShootEffect(trace)
            self:DealDamage(trace, dmgbullet)
        end
    }

    local s = self.Owner:FireBullets( bullet )
    self:CallOnClient("ShootGunEffect")
    self:ShootEffects()
    self:MakeRecoil()

end

function SWEP:PrimaryAttack()
 
end

function SWEP:SecondaryAttack()

end

function SWEP:BroadcastShootEffect(trace)
    net.Start("gs_weapon_base_effect")
    net.WriteEntity(trace.Entity)
    net.WriteVector(trace.HitPos)
    net.WriteVector(trace.StartPos)
    net.WriteInt(trace.SurfaceProps, 8)
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

function SWEP:StripMagazine()
    if self:GetOwner():GetActiveWeapon() != self then
        self:GetOwner():ChatPrint("You need to hold a gun in your hands")
        return false
    end

    if self.magazine == nil then
        return
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

    self:GetOwner():ChatPrint("You stripped magazine from "..self.Entity_Data.Name..".")
    self:ReloadGunEffect()
    self:TriggerLoadWorldModel(self.magazine != nil)
end

function SWEP:StripMagazineHand()
    if self:GetOwner():GetActiveWeapon() != self then
        self:GetOwner():ChatPrint("You need to hold a gun in your hands")
        return false
    end

    if self.magazine == nil then
        return
    end

    local hand = self:GetOwner():GetWeapon( "gs_swep_hand" )
    local succes = hand:PutItemInHand(self.magazine)
    if succes then
        self.magazine = nil
        self:GetOwner():ChatPrint("You stripped magazine from "..self.Entity_Data.Name.." and put in hand")
        self:ReloadGunEffect()
        self:TriggerLoadWorldModel(self.magazine != nil)
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

    if self.ammo_type != ent.Entity_Data.Weapon_Magazine then
        return false
    end

    self.magazine = ent

    self:ReloadGunEffect()
    self:TriggerLoadWorldModel(self.magazine != nil)
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
--[[
function SWEP:CanChangeWeapon()
    if self.reloadTime > CurTime() then
        return false
    end
    return true
end
--]]
function SWEP:ReloadGunEffect()
    if self:GetOwner():GetActiveWeapon() != self then
        return
        --self:GetOwner():ChatPrint("You need to hold a gun in your hands")
    end
    self:SendWeaponAnim(ACT_VM_RELOAD)
    self:EmitSound(self.ReloadSound)
    self:GetOwner():SetAnimation(PLAYER_RELOAD)

    local reloadtime = self.Owner:GetViewModel():SequenceDuration() + 0.1

    self.delay = CurTime() + reloadtime
    self.reloadTime = CurTime() + reloadtime

    timer.Simple(reloadtime, function()
        self:SetActivity(ACT_VM_IDLE)
    end)
end

function SWEP:TriggerLoadWorldModel(bool)
    net.Start("gs_weapon_base_set_magazine_model")
    net.WriteEntity(self)
    net.WriteBool(bool)
    net.Broadcast()
end

