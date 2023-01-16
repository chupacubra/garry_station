AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function SWEP:CompareWithEnt(ent)
    if self.action_type == GS_AW_MAGAZINE then
        return self:InsertMagazine(ent)
    end
    --return nil
end 

function SWEP:PrimaryAttack()
    if self.magazine == nil then
        return
    end

    if self.delay > CurTime() then
        return
    end

    local bullet = self.magazine.Private_Data.Magazine[self.magazine.Private_Data.Bullets]
    if bullet == nil then
 --       print("no bullets")
        return
    end
    self:MakeSingleShoot(bullet)
    self.delay = CurTime() + self.shoot_speed

    self.magazine.Private_Data.Magazine[self.magazine.Private_Data.Bullets] = nil
    self.magazine.Private_Data.Bullets = self.magazine.Private_Data.Bullets - 1
end

function SWEP:SecondaryAttack()

end
