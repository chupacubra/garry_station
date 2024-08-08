-- for high tech googles 
-- BUT
-- is some client func, and we have some problems here (or not)
-- idk

--[[

dont know it was so relaible

function ENT:EquipInit()
    ENT.PlyEquiped = NULL
    ENT.Equiped    = false
end


=========
strange and nor relaible code, need rework
need shared version
--]]


if CLIENT then 
    function ENT:PlayerEquip()
        // something shitt
    end

    function ENT:PlayerDequip()
        // something poop
    end

    function ENT:DrawHUD()
        // if type of googles or smthng
        // we can draw custom HUD
    end
end

if SERVER then
    function ENT:SyncBroadcast()
        // broadcast to all cowards, about we equip the cooooool hat
        // this oonly for custom editing ?
    end

    function ENT:SyncToClient()
        // msg to one faggot, who equip stinky cap
    end

    function ENT:Equip(ply)
        // save our ply
        // and send to client info about we equip
        //self:BeforeEquip(ply)

        self.PlyEquiped = NULL
        self.Equiped    = true
        
        //self:BeforeEquip()
    end
    
    function ENT:BeforeEquip(ply)
        // custom
    end

    function ENT:PostEquip()
        // custom
    end

    function ENT:DeEquip()
        self.PlyEquiped = NULL
        self.Equiped    = false
    end
end



