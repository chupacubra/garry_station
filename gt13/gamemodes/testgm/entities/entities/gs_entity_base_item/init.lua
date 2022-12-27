AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    PrintTable(self.Entity_Data)
    if self.Entity_Data then
        self:SetModel(self.Entity_Data.Model or "models/props_junk/cardboard_box004a_gib01.mdl")
    else
        self:SetModel(self:GetModel())
    end
    self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end

end

function ENT:SetItemModel(model)
    self.Entity_Data.Model = model or ""
    self:SetModel(model)
end


function ENT:SetData(data)
    self.Entity_Data = data
    if self.Entity_Data.Model then
        self:SetModel(self.Entity_Data.Model)
    end
end

function ENT:SetPrivateData(data)
    self.Private_Data = data
end

function ENT:GetPrivateData()
    return self.Private_Data
end

function ENT:GetHandData()
    return self.Entity_Data
end


function ENT:LoadInfoAboutItem() -- !!!!!! 
    net.Start("gs_ent_update_info_item")
    net.WriteEntity(self)
    net.WriteTable(self.Entity_Data)
    net.Broadcast()
end

net.Receive("gs_ent_client_init_item", function()
    local ent = net.ReadEntity()
    ent:LoadInfoAboutItem() 
end)

function ENT:OnReloaded() 
    self:SetData(self.Entity_Data)
    self:LoadInfoAboutItem()
end
