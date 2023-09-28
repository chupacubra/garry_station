include("shared.lua")

function ENT:Initialize()
    self.ConnectedToEnt = false

    self:CallOnRemove( "DisconnectPly", function()
        if self.ConnectedToEnt then
            self:DisconnectPly(true)
        end
    end)
end

function ENT:Examine()
    net.Start("gs_ent_request_examine")
    net.WriteEntity(self)
    net.SendToServer()
end

function ENT:Draw()
    self:DrawModel()
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

function ENT:ConnectPly()
    timer.Create("gs_cl_ent_connect_"..tostring(self:EntIndex()), function()
        if !self:IsVaild() then
            timer.Remove("gs_cl_ent_connect_"..tostring(self:EntIndex()))
        end
        
        net.Start("gs_ent_connect_ply")
        net.WriteEnt(self)
        net.WriteBool(true)
        net.SendToServer()
    end)

    self.ConnectedToEnt = true
end

function ENT:DisconnectPly(fromServer)
    timer.Remove("gs_cl_ent_connect_"..tostring(self:EntIndex()))

    if !fromServer then
        net.Start("gs_ent_connect_ply")
        net.WriteEnt(self)
        net.WriteBool(false)
        net.SendToServer()
    end

    self.ConnectedToEnt = false

end

net.Receive("gs_ent_connect_ply", function()
    local ent = net.ReadEntity()

    ent:DisconnectPly(true)
end)