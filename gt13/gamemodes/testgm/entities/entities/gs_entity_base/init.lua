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

net.Receive("gs_ent_client_init", function()
    local ent = net.ReadEntity()
    ent:LoadInfoAbout()
end)

function ENT:OnReloaded()
    self:LoadInfoAbout()
end