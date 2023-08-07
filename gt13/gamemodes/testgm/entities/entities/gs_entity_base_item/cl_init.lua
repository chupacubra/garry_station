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

function ENT:GetRequest(dat)
    self.req_data.received = true
    self.req_data.data = dat
end

function ENT:Examine(request, data) -- if bool then
    net.Start("gs_ent_request_examine")
    net.WriteEntity(self)
    net.SendToServer()
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

net.Receive("gs_ent_update_info_item", function()
    local ent  = net.ReadEntity()
    local data = net.ReadTable()
    local id   = net.ReadString()
    local typ = net.ReadString()

    print(ent)
    print(data)

    debug.Trace()
    ent.Entity_Data = data

    if id == "" or typ == "" then
        return
    end

    ent.Data_Labels = {id = id, type = typ}
    --[[
        check for having context buttons in files
    ]]
    print(typ, id)
    local tbl = GS_EntityList[typ][id]

    if tbl.GetContextButtons then
        ent.GetContextButtons = tbl.GetContextButtons
    end
end)

net.Receive("gs_ent_get_private_info",function()
    local ent = net.ReadEntity()
    local ex_d = net.ReadTable()

    ent:Examine(true, ex_d)
end)

-- kopec
