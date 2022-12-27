AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function SWEP:Initialize()
    self:SetHoldType( "pistol" )
    self.magazine = self.magazine or {}
end

function SWEP:PrimaryAttack()
    if self.delay > CurTime() then
        return
    end

    self:MakeSingleShoot()
    self.delay = CurTime() + self.shoot_speed
    self:EmitSound("Weapon_Pistol.Single")

end

function SWEP:SecondaryAttack()
    if self.delay > CurTime() then
        return
    end

    self:MakeSingleShoot()
    self.delay = CurTime() + self.shoot_speed
    self:EmitSound("Weapon_Pistol.Single")
end
