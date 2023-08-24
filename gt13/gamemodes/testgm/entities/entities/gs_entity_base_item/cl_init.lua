include("shared.lua")

function ENT:Initialize()
end

function ENT:OnReloaded() 
end

function ENT:Examine(request, data) -- if bool then
    if self.Entity_Data.Simple_Examine then
        LocalPlayer():ChatPrint("It's "..self.Entity_Data.Name )
        LocalPlayer():ChatPrint( self.Entity_Data.Desc )
    else
        net.Start("gs_ent_request_examine")
        net.WriteEntity(self)
        net.SendToServer()
    end
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:GS_Equip()
    net.Start("gs_ply_equip_item")
    net.WriteEntity(LocalPlayer())
    net.WriteEntity(self)
    net.SendToServer()
end

function ENT:AddContextMenu()
    if !self.GetContextButtons then
        return {}
    end

    return self.GetContextButtons(self, CB_FLOOR)
end

function ENT:GetContextMenu()
    local contextButton = {}
    
    if self.CanExamine then
        local button = {
            label = "Examine",
            icon  = "icon16/eye.png",
            click = function()
                local examine = self:Examine()
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

    if self.Entity_Data.ENUM_Type == GS_ITEM_EQUIP then
        local button = {
            label = "Equip",
            icon  = "icon16/tag_orange.png",
            click = function()
                self:GS_Equip()
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

-- kopec
