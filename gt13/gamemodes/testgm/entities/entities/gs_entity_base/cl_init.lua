include("shared.lua")

function ENT:Initialize()
    net.Start("gs_ent_client_init")
    net.WriteEntity(self)
    net.SendToServer()
end

function ENT:Examine()
    net.Start("gs_ent_request_examine")
    net.WriteEntity(self)
    net.SendToServer()
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:OnReloaded() 
    net.Start("gs_ent_client_init")
    net.WriteEntity(self)
    net.SendToServer()
end

function ENT:AddContextMenu() -- need for adding new buttons
    return nil
end

function ENT:GetContextMenu()
    local contextButton = {}
    
    if self.CanExamine then
        local button = {
            label = "Examine",
            icon  = "icon16/eye.png",
            click = function()
                self:Examine()
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

    local button = {
        label = "Grab",
        icon  = "icon16/link.png",
        click = function()
            net.Start("gs_ent_grab")
            net.WriteEntity(self)
            net.SendToServer()
        end
    }
    table.insert(contextButton,button)

    local add = self:AddContextMenu()
    
    if add then
        table.Add(contextButton, add)
    end
    
    return contextButton
end

--[[
net.Receive("gs_ent_update_info", function()
    local ent = net.ReadEntity()
    local tab = net.ReadTable()
    ent.Entity_Data = tab
end)
--]]