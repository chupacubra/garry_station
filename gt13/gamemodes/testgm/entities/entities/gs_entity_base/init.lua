AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SetExamine(data) -- name, description
    if data == false then
        return
    end

    self.Entity_Data.Name = data.name 
    self.Entity_Data.Desc = data.desc
    self:LoadInfoAbout()
end

function ENT:SetData(data) 
    self.Entity_Data = data
    if self.Entity_Data.Model then
        self:SetModel(self.Entity_Data.Model)
    end
end

function ENT:Examine()
    if self.canExamine then
        return self.Entity_Data.Name, self.Entity_Data.Desc
    end
end

function ENT:Breakable(hp)
    if hp == false then
        self:SetCanBreak(false)
        return
    end
    
    self.HP = hp 
end

function ENT:EDamage(dmg)
    if !self:CanBreak() then
        return false
    end

    self.HP = self.HP - dmg

    if self.HP <= 0 then
        self:AfterBreak()
    end
end

function ENT:AfterBreak()
    self:Remove()
end

function ENT:LoadInfoAbout() -- !!!!!! 
    net.Start("gs_ent_update_info")

    net.WriteEntity(self)
    net.WriteTable(self.Entity_Data)
    net.Broadcast()
end

function ENT:OnReloaded()
    self:LoadInfoAbout()
end


function ENT:GrabEntity(ply)
    if !self:OnGround() then
        return
    end

    if self.GrabPlayer then
        if self.GrabPlayer == ply then
            self:UnGrabEntity() -- simple ungrab
            return
        else
            self:UnGrabEntity() -- drive by entity
        end
    end
    self.GrabPlayer = ply
    self.Grabed     = true
    self.GrabPos    = ply:WorldToLocal(self:GetPos())
    self.GrabAng    = self:GetAngles()
    self.GrabMat    = self:GetPhysicsObject():GetMaterial()

    player_manager.RunClass( ply, "EffectSpeedAdd", "grab_entity", -150, -350 )
    construct.SetPhysProp( self:GetOwner(), self, 0, nil, { GravityToggle = true, Material = "slipperyslime" } )
    GS_ChatPrint(self.GrabPlayer, "You grab the "..self.Entity_Data.Name)
    
end

function ENT:UnGrabEntity()
    if self.GrabPlayer then
        player_manager.RunClass( self.GrabPlayer, "EffectSpeedRemove", "grab_entity")
        GS_ChatPrint(self.GrabPlayer, "You stop grabbing "..self.Entity_Data.Name)
    end

    construct.SetPhysProp( self:GetOwner(), self, 0, nil, { GravityToggle = true, Material = self.GrabMat } )

    self.GrabPlayer = nil
    self.Grabed     = false
    self.GrapPos    = nil
    self.GrabAng    = nil
    self.GrabMat    = nil
end

function ENT:Think()
    if self.Grabed then
        if !IsValid(self.GrabPlayer) then
            self:UnGrabEntity()
            return
        end

        local dist = self:GetPos():Distance( self.GrabPlayer:LocalToWorld(self.GrabPos))
        if dist > 100 then
            self:UnGrabEntity()
            return
        end

        if dist > 10 then
            local pos = self.GrabPlayer:LocalToWorld(self.GrabPos)
            local phys = self:GetPhysicsObject()

            local cpos = pos - self:GetPos()

            cpos:Normalize()

            local force = cpos * dist

            phys:SetVelocity(force)            
        end
    end
end

function ENT:Bolt()

    if self:GetVelocity() != Vector(0,0,0) then
        return false
    end
    
    self:GetPhysicsObject():EnableMotion( false )
    self:SetKeyState("bolt",true)
    return true, "You screwed this in ground"
end

function ENT:Unbolt()
    self:GetPhysicsObject():EnableMotion( true )
    self:SetKeyState("bolt",false)
    return true, "You unscrewed this from ground"
end

--[[
    STATE
    
    self.Entity_Status = {
        build     = bool, vendomat or machine casing
        maintance = bool, open maintance hatchet
        bolt      = bool, screwed to the ground
        broken    = bool
    }
]]

function ENT:SetupState()
    self.Entity_Status = {
        build     = false,
        maintance = false,
        bolt      = false,
        broken    = false,
    }
end

function ENT:AddKeyState(key, base)
    self.Entity_Status[key] = base
end

function ENT:SetKeyState(key,base)
    self.Entity_Status[key] = base
end 

function ENT:GetState()
    return self.Entity_Status
end

function ENT:GetKeyState(key)
    return self.Entity_Status[key]
end
--[[
examples and base actions on tool
--]]

function ENT:Wrench(ply)
    if self.CanBolted then
        if self:GetKeyState("bolt") == false then
            return self:Bolt()
        else
            return self:Unbolt()
        end
    end
end

function ENT:Crowbar(ply)
--[[
    ex if build and maint open --> uncraft machine
]]
end

function ENT:Screwdriver(ply)
--[[
    open maint
    machine casing build
]]
end

function ENT:Multitool(ply)

end

net.Receive("gs_ent_client_init", function()
    local ent = net.ReadEntity()
    ent:LoadInfoAbout()
end)

net.Receive("gs_ent_grab", function(_,ply)
    local ent = net.ReadEntity()
    ent:GrabEntity(ply)
end)
