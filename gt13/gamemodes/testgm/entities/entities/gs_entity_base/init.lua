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

function ENT:SetupFlag()
    self.Key_State = 0
end

function ENT:SetFlagState(key, flag)
    if flag then
        self.Key_State = bit.bor(self.Key_State, 2^key)
    else
        self.Key_State = bit.bxor(self.Key_State, 2^key)
    end

end 

function ENT:GetFlagState(key)
    local k = 2 ^ key

    return bit.band(self.Key_State, k) == k
end

function ENT:GetFlag()
    return self.Key_State
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


function ENT:Bolt()
    if self:GetVelocity() != Vector(0,0,0) then
        return false
    end
    
    self:GetPhysicsObject():EnableMotion( false )
    self:SetFlagState(KS_BOLT,true)
    return true, "You screwed this in ground"
end

function ENT:Unbolt()
    self:GetPhysicsObject():EnableMotion( true )
    self:SetFlagState(KS_BOLT,false)
    return true, "You unscrewed this from ground"
end

function ENT:Wrench(ply)
    if self.CanBolted then
        if self:GetFlagState(KS_BOLT) == false then
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
