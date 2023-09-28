AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.magazine = {
    limit = 8,
    ammo = {}
}

function SWEP:CompareWithEnt(ent)
    -- can only compare with shotgun shells = reload
    -- shotgun shells in shels box
    if ent.Entity_Data.ENUM_Type == GS_ITEM_AMMO_PILE and ent.Entity_Data.ENUM_Subtype == GS_W_SHOTGUN then
        return self:InsertBullet(ent)
    end
end

function SWEP:PrimaryAttack()
    local bullet = self.magazine.ammo[1]
    
    if bullet == nil then
        return
    end

    self:MakeSingleShoot(bullet.BulletDamage, bullet.Mod)
    table.remove(self.magazine.ammo, 1)
    self:SetNextPrimaryFire(CurTime() + self.shoot_speed)
end

function SWEP:SecondaryAttack()

end

function SWEP:Reload()
    -- make shick-shick -- eject ammo (ammo pile)
end
