AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.magazine = {
    limit = 8,
    ammo = {},
    current = nil,
}

function SWEP:CompareWithEnt(ent)
    -- can only compare with shotgun shells BOX/PILE = reload
    -- shotgun shells in shels box
    if ent.Entity_Data.ENUM_Type == GS_ITEM_AMMO_PILE and ent.Entity_Data.ENUM_Subtype == GS_W_SHOTGUN then
        print("INSERT SHELL")
        return self:InsertBullet(ent)
    end
end

function SWEP:PrimaryAttack()
    local bullet = self.magazine.current
    
    if !bullet then
        return
    end

    self:MakeSingleShoot(bullet)
    
    if #self.magazine.ammo > 0 then
        self.magazine.current = self.magazine.ammo[1]
        table.remove(self.magazine.ammo, 1)
    else
        self.magazine.current = nil
    end

    self:SetNextPrimaryFire(CurTime() + self.shoot_speed)
end


