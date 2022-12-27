include("shared.lua")

function ENT:Initialize()
    net.Start("gs_ent_client_init_item")
    net.WriteEntity(self)
    net.SendToServer()
end

function ENT:OnReloaded() 
    net.Start("gs_ent_client_init_item")
    net.WriteEntity(self)
    net.SendToServer()
end

function ENT:Examine()
    local name, desc = self.Entity_Data.Name, self.Entity_Data.Desc
    local exTable = {name, desc}
    if self.Entity_Data.ENUM_Type == GS_ITEM_CONTAINER then
        local unit = self.Entity_Data.CountChemicals
        if unit != 0 then 
            table.insert(exTable, "Have ".. unit .." units")
        else
            table.insert(exTable, "This is empty")
        end
    elseif self.Entity_Data.ENUM_Type == GS_ITEM_AMMOBOX then
        local ammo = self.Entity_Data.AmmoInBox 

        if ammo != 0 then
            table.insert(exTable,"Have "..ammo.." bullets")
        else
            table.insert(exTable,"No ammo")
        end
    end
    return exTable
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:GS_Equip()

end

function ENT:GetContextMenu()
    local contextButton = {}
    
    if self.CanExamine then
        local button = {
            label = "Examine",
            icon  = "icon16/eye.png",
            click = function()
                local examine = self:Examine()
                for k,v in pairs(examine) do
                    if k == 1 then
                        v = "It is ".. v
                    end
                    LocalPlayer():ChatPrint(v)
                end
            end
        }
        table.insert(contextButton, button)
    end

    if self.CanUse then
        local button = {
            label = "Use",
            icon  = "icon16/resultset_next.png" ,
            click = function()
                self:Use()
            end
        }
        table.insert(contextButton, button)
    end

    if self.IsGS_Weapon then
        local button = {
            label = "Use",
            icon = "icon16/add.png", 
            click = function()
                self:GS_Pickup()
            end
        }
        table.insert(contextButton, button)
    end

    if self.IsGS_Equip then
        local button = {
            label = "Equip",
            icon  = "icon16/tag_orange.png",
            click = function()
                self:GS_Equip()
            end 
        }
        table.insert(contextButton, button)
    end

    return contextButton
end



net.Receive("gs_ent_update_info_item", function()
    local ent = net.ReadEntity()
    print(ent)
    local data = net.ReadTable()
    
    ent.Entity_Data = data
end)