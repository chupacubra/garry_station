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
    self.magazine = self.magazine 
    self:TriggerLoadWorldModel()
end

function SWEP:OnDrop()
    self:TriggerLoadWorldModel()
end

function SWEP:Deploy()
    self:SetHoldType(self.HoldType)
end

function SWEP:PumpSlide()
    table.remove(self.magazine.ammo, 1)
    -- start animation slide
    -- ACT_VM_PULLBACK
    -- ACT_SHOTGUN_PUMP
    self:PumpSlideAnim()
end

function SWEP:PumpSlideAnim()
    -- get anim of pump slide
    local VModel = self:GetOwner():GetViewModel()   
    VModel:SendViewModelMatchingSequence( 0 )
    --self:GetOwner():SetAnimation( PLAYER_RELOAD )
    self:SendWeaponAnim( ACT_SHOTGUN_PUMP )
end

function SWEP:Reload()
    -- base action (+alt key): reload ammo with ammobelt
    -- if gun = shotgun then make pump slide action
    if self:GetOwner():KeyPressed(IN_WALK) then
        -- reload with ammobelt
        return
    end
    
    if self.action_type == GS_AW_PUMP then
        self:PumpSlide()
    end
end

function SWEP:DealDamage(trace, dmgbullet)
    local dmgbul = all_dmg(dmgbullet)

    local force = trace.Normal * dmgbul * 10

    if trace.Entity:IsPlayer() then
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

function SWEP:MakeSingleShoot(dmgbullet, modif)
    local spr = self.spread
    local num = 1
    local recoil = self.recoil

    if modif then
        local spr =  modif.Spread or spr 
        local num = modif.Amount or num
        local recoil = modif.recoil or recoil
    end

    self:SetNWInt("Num", num)
    self:SetNWInt("Spr", spr)

    local bullet = {
        Damage = all_dmg(dmgbullet),
        Force = all_dmg(dmgbullet) * 2,
        TracerName = "Tracer",
        Src = self.Owner:GetShootPos(),
        Dir = self.Owner:GetAimVector(),
        Spread = Vector(spr, spr),
        Num = num,
        Callback = function(ent, trace)
            self:DealDamage(trace, dmgbullet)
        end
    }

    self:FireBullets(bullet, false)
    self:CallOnClient("ShootGunEffect")
    self:ShootEffects()
    self:MakeRecoil(recoil)
end

function SWEP:PrimaryAttack()
 
end

function SWEP:SecondaryAttack()

end

function SWEP:MakeRecoil(r)
    self:GetOwner():ViewPunch( Angle( -r, math.random(-1, 1) * r, 0 ) )
end

function SWEP:GS_PickupWeapon(ply)
	if ply:HasWeapon( self:GetClass() ) or #ply:GetWeapons() == 4 then
		return false
	end
	ply:PickupWeapon( self, false )
end

function SWEP:StripMagazine()
    if self.action_type == GS_AW_PUMP or self.action_type == GS_AW_BOLT then
        -- cant strip magazine from shotgun and bolt rifles
        return
    end

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
    if self.action_type == GS_AW_PUMP or self.action_type == GS_AW_BOLT then
        return
    end

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

function SWEP:InsertBullet(ammo_pile)
    if self.magazine.limit <= #self.magazine.ammo then
        self:GetOwner():ChatPrint("The weapon is full!")
        return false
    end

    -- if shotgun then shell going first to shot
    table.insert(self.magazine.ammo, self.action_type == GS_AW_PUMP and 1 or nil , ammo_pile.Private_Data.Bullet)

    ammo_pile.Private_Data.Stack = ammo_pile.Private_Data.Stack - 1

    if ammo_pile.Private_Data.Stack < 1 then
        return nil
    end

    return ammo_pile
end

net.Receive("gs_ply_pickup_weapon",function(_, ply)
    local weap = net.ReadEntity()

    weap:GS_PickupWeapon(ply)
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

    timer.Simple(reloadtime, function()
        self:SetActivity(ACT_VM_IDLE)
    end)

    self:SetNextPrimaryFire(CurTime() + reloadtime)
end

function SWEP:TriggerLoadWorldModel()
    self:SetNWBool("magazine", self.magazine != nil)
end

concommand.Add("gs_weapon_strip_magazine", function(ply, str, arg)
    local weap = ply:GetActiveWeapon()
    
    if weap:IsValid() and weap.IsGS_Weapon then
        local bool = tobool(arg[1])

        if bool then
            weap:StripMagazineHand()
        else
            weap:StripMagazine()
        end
    end
end)