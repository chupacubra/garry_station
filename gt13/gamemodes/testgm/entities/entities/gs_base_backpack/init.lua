AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Entity_Data.Model or "models/props_junk/cardboard_box004a_gib01.mdl")
    self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end
    --self.item_container = {}
end

function ENT:SetEntity_Data(itemData)
    self.Entity_Data = itemData
    self:LoadInfoAboutItem()

end

function ENT:SetPrivate_Data(privData)
    self.Private_Data = privData
end

function ENT:LoadInfoAboutItem() -- !!!!!!!!!!!! client metod in base_item
    net.Start("gs_ent_update_info_item")
    net.WriteEntity(self)
    net.WriteTable(self.Entity_Data)
    net.Broadcast()
end

--[[
function ENT:CanInsertItem()
    if #self.item_container >= self.max_items then
        return false
    end
    return true
end

function ENT:GetItems()
    return self.item_container
end
--[[
function ENT:EquipEquipment(ply)
    local data = {}
    data.name = self.EName
    data.desc = self.Desc
    data.max_items = self.max_items
    data.etype = self.etype
    data.model = self.backpack_model

    data.items = self.item_container

    self:Remove()
    return data
end


function ENT:InsertItem(itemData)
    if !self:CanInsertItem() then
        return
    end

    table.insert(self.item_container, itemData)
end

function ENT:GetItemFromBackack(key)
    if self.item_container[key] then
        local data = self.item_container
        table.remove(self.item_container, key)
        return data
    end
end
--]]
