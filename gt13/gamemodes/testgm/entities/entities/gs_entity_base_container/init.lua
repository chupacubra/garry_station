AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Use()

end

function ENT:GetItemsContainer()
    return self.Private_Data.Items
end

function ENT:InsertItemInContainer(item)
    if #self.Private_Data.Items + 1 > self.Private_Data.Max_Items then
        return false
    end

    table.insert(self.Private_Data.Items, item)
end

function ENT:RemoveItemFromContainer(key)
    if self.Private_Data.Items[key] == nil then
        return false
    end

    table.remove(self.Private_Data.Items, key)
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
end

net.Receive("gs_ent_container_open", function(_, ply)
    local ent = net.ReadEntity()

    player_manager.RunClass( ply, "OpenContainer", ent)
end)