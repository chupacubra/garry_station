include("shared.lua")

function ENT:Examine()
    local name, desc = self.Entity_Data.Name, self.Entity_Data.Desc
    local exTable = {name, desc}

    return exTable
end

function ENT:GS_Equip(ply)
    net.Start("gs_ply_equip_item")
    net.WriteEntity(ply)
    net.WriteEntity(self)
    net.SendToServer()
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

    if self.GS_Equipable then
        local button = {
            label = "Equip",
            icon  = "icon16/tag_orange.png",
            click = function()
                self:GS_Equip(LocalPlayer())
            end 
        }
        table.insert(contextButton, button)
    end

    return contextButton
end

function ENT:Draw()
    self:DrawModel()
end

net.Receive("gs_ent_update_info_item", function()
    local ent = net.ReadEntity()
    print(ent)
    local data = net.ReadTable()
    
    ent.Entity_Data = data
end)

