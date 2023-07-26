include("shared.lua")

function ENT:Initialize()
    net.Start("gs_ent_client_init")
    net.WriteEntity(self)
    net.SendToServer()
end

function ENT:Examine()
    local name, desc = self.Entity_Data.Name, self.Entity_Data.Desc
    local exTable = {name, desc}

    return exTable
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:OnReloaded() 
    net.Start("gs_ent_client_init")
    net.WriteEntity(self)
    net.SendToServer()
end

function ENT:GetContextMenu()
    local contextButton = {}

    local button = {
        label = "Examine",
        icon  = "icon16/eye.png",
        click = function()
            net.Start("gs_ent_request_examine")
            net.WriteEntity(self)
            net.SendToServer()
        end
    }
    table.insert(contextButton, button)


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

function ENT:OpenDerma(derma)
    OpenCompFrame(self, derma)
end


function ENT:RequestDataFromServer(data_name)

end


net.Receive("gs_ent_update_info", function()
    local ent = net.ReadEntity()
    local tab = net.ReadTable()
    ent.Entity_Data = tab
end)

net.Receive("gs_comp_show_derma", function()
    local ent = net.ReadEntity()
    local board = net.ReadString()

    ent:OpenDerma(board)
end)