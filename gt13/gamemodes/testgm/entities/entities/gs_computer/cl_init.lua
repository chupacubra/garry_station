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
    if derma then

    end
end


function ENT:RequestDataFromServer(data_name)

end




net.Receive("gs_ent_update_info", function()
    local ent = net.ReadEntity()
    local tab = net.ReadTable()
    ent.Entity_Data = tab
end)

net.Receive()