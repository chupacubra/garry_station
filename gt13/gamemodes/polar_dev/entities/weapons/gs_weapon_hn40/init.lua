AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function SWEP:CompareWithEnt(ent)
    if self.action_type == GS_AW_MAGAZINE then
        return self:InsertMagazine(ent)
    end
    --return nil -- update magazin in inventory to NIL -> remove
    return false
end 

function SWEP:PrimaryAttack()
    self:MagazineShot()
end
