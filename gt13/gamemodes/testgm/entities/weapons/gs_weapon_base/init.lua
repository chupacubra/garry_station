AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local function all_dmg(dmg)
    local ad = 0
    PrintTable(dmg)
    for _,v in pairs(dmg) do
        --for _,vv in pairs(v) do
            ad = ad + v
        --end
    end
    return ad
end

function SWEP:Initialize()
    self:SetHoldType( self.HoldType )
    self.magazine = self.magazine
    self.PumpT = 0 
    self:TriggerLoadWorldModel()
end

function SWEP:OnDrop()
    self:TriggerLoadWorldModel()
    self:SetNWBool("Zoom", false)
end

function SWEP:Deploy()
    self:SetHoldType(self.HoldType)
    self:SetNWBool("Zoom", false)
end

function SWEP:PumpSlide()
    if self.PumpT > CurTime() then return end
    
    if !self.magazine.current then
        if #self.magazine.ammo > 0 then
            self.magazine.current = self.magazine.ammo[1]
            table.remove(self.magazine.ammo, 1)

            local reloadtime = self:PumpSlideAnim()
            self.PumpT = CurTime() + reloadtime
        
            self:SetNextPrimaryFire(self.PumpT)
        end
    else
        local shell = self.magazine.current
        self.magazine.current = nil
        local name_ap = shell.apn
    
        local ent = ents.Create("gs_item_shotgun_ammo_"..name_ap)
        ent:SetPos(self:GetPos())
        
        local phys = ent:GetPhysicsObject()
    
        if phys then
            phys:ApplyForceCenter(self:GetOwner():GetAimVector() * 15)
        end
    
        local reloadtime = self:PumpSlideAnim()
        self.PumpT = CurTime() + reloadtime
    
        self:SetNextPrimaryFire(self.PumpT)
    end

    
    --[[
    if #self.magazine.ammo < 1 then return end

    local shell = self.magazine.ammo[1]
    table.remove(self.magazine.ammo, 1)
    local name_ap = shell.apn

    local ent = ents.Create("gs_item_shotgun_ammo_"..name_ap)
    ent:SetPos(self:GetPos())
    
    local phys = ent:GetPhysicsObject()

    if phys then
        phys:ApplyForceCenter(self:GetOwner():GetAimVector() * 15)
    end

    local reloadtime = self:PumpSlideAnim()
    self.PumpT = CurTime() + reloadtime

    self:SetNextPrimaryFire(self.PumpT)
    --]]
end

function SWEP:PumpSlideAnim()
    -- get anim of pump slide
    local VModel = self:GetOwner():GetViewModel()   
    VModel:SendViewModelMatchingSequence( self.AnimList.pump_slide )
    self:GetOwner():SetAnimation( PLAYER_RELOAD )
    --self:EmitSound(self.ReloadSound)

    return VModel:SequenceDuration()
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

function SWEP:MakeSingleShoot(bullet)
    local spr = self.spread
    local num = 1
    local recoil = self.recoil

    local dmgbullet = bullet.BulletDamage
    local modif = bullet.Mod

    --PrintTable(modif)

    if modif then
        spr =  modif.Spread or spr 
        num = modif.Amount or num
        recoil = modif.Recoil or recoil
    end

    print(spr, num, recoil)
    --self:SetNWInt("Num", num)
    --self:SetNWInt("Spr", spr)

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

    if modif then
        net.Start("gs_weapon_base_effect")
        net.WriteEntity(self)
        net.WriteUInt(num, 5)
        net.WriteUInt(spr * 100, 8)
        net.Broadcast()
    end
end

function SWEP:PrimaryAttack()
 
end

function SWEP:SecondaryAttack()
    if self.CanZoom then
        self:SetNWBool("Zoom", !self:GetNWBool("Zoom"))
    end
end

function SWEP:MagazineShot()
    if self.magazine == nil then
        return
    end

    if self.magazine.Private_Data.Bullets < 1 then
        self:EmitSound(self.EmptySound)
        return
    end

    local bullet = self.magazine.Private_Data.Magazine[self.magazine.Private_Data.Bullets]

    self:MakeSingleShoot(bullet)

    self.magazine.Private_Data.Magazine[self.magazine.Private_Data.Bullets] = nil
    self.magazine.Private_Data.Bullets = self.magazine.Private_Data.Bullets - 1

    self:SetNextPrimaryFire(CurTime() + self.shoot_speed)
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
    local success = hand:PutItemInHand(self.magazine)

    if success then
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

    --self:ReloadGunEffect()
    --self:PumpSlideAnim()

    self:SendWeaponAnim(ACT_VM_RELOAD)
    self:EmitSound(self.ReloadSound)
    self:GetOwner():SetAnimation(PLAYER_RELOAD)

    local reloadtime = self.Owner:GetViewModel():SequenceDuration() + 0.1

    timer.Simple(reloadtime, function()
        self:SetActivity(ACT_VM_IDLE)
        self:SendWeaponAnim(ACT_VM_IDLE)
        self:GetOwner():SetAnimation(PLAYER_IDLE)
        --self:PumpSlideAnim()
    end)

    self:SetNextPrimaryFire(CurTime() + reloadtime)

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
        --if self.action_type == GS_AW_PUMP then
        --    self:PumpSlideAnim()
        --end
    end)

    self:SetNextPrimaryFire(CurTime() + reloadtime)
end

function SWEP:TriggerLoadWorldModel()
    if !self.HaveUnloadModel then return end
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

concommand.Add("gs_weapon_pump_slide", function(ply, str, arg)
    local weap = ply:GetActiveWeapon()
    
    if weap:IsValid() and weap.IsGS_Weapon then
        weap:PumpSlide()
    end
end)