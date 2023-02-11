AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
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

    self.ContainerUser = Entity(0)

end
 
function ENT:Use()

end

function ENT:GetItemsContainer()
    return self.Private_Data.Items
end

function ENT:GetItemFromContainer(key)
    return self.Private_Data.Items[key]
end

function ENT:InsertItemInContainer(item)
    if #self.Private_Data.Items + 1 > self.Private_Data.Max_Items then
        return false
    end

    table.insert(self.Private_Data.Items, item)
    player_manager.RunClass( self.ContainerUser, "OpenEntContainer", self)
    return true
end

function ENT:RemoveItemFromContainer(key)
    if self.Private_Data.Items[key] == nil then
        return false
    end

    table.remove(self.Private_Data.Items, key)
    player_manager.RunClass( self.ContainerUser, "OpenEntContainer", self)
end

function ENT:UpdateItemInContainer(item, key)
    if self.Private_Data.Items[key] == nil then
        return false
    end
    
    if item == nil then
        self:RemoveItemFromContainer(key)
        return
    end

    self.Private_Data.Items[key] = item
    player_manager.RunClass( self.ContainerUser, "OpenEntContainer", self)
end

function ENT:Think()
    if self.ContainerUser:IsValid() then
        if self:GetPos():Distance(self.ContainerUser:GetPos()) > 80 then
            player_manager.RunClass( self.ContainerUser, "CloseEntContainer")
            GS_MSG(self.ContainerUser:GetName()  .." out of box",MSG_INFO)
            self.ContainerUser = Entity(0)
        end
    end
end

function ENT:OnRemove()
    if self.ContainerUser:IsValid() then
        player_manager.RunClass( self.ContainerUser, "CloseEntContainer")
    end
end