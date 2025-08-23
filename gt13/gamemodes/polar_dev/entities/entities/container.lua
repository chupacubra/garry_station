// some hint
// "физический" перенос предмета в другой на себя берёт получающий контейнер (SetParentContainer)
// при удалении предмета из первого же удалит только из таблицы

AddCSLuaFile()

ENT.IsContainer = false
ENT.MaxItems    = 6
ENT.ItemMaxSize = ITEM_MEDIUM


function ENT:ContainerInit() // post init
    if self.IsContainer then
        self.Items = {}
        if SERVER then
            self:AddToThink("ThinkContainerCheck", self.ThinkContainerCheck)
        end
    end
end

function ENT:GetItems()
    return self.Items
end

function ENT:GetItem(key)
    if !self.IsContainer then return end

    return self.Items[key]
end



function ENT:SetItems(tbl)
    if !self.IsContainer then return end

    self.Items = tbl
end

function ENT:InsertItemInContainer(item)
    print("cont", self, item)
    if !self.IsContainer then return end

    print("cont", self, item)
    if table.Count(self.Items) + 1 > self.MaxItems then
        return false
    end

    if self.ItemMaxSize < item.Size then
		//self.ContainerUser:ChatPrint(item.Name.." is not fit in "..self.Name)
		return false
	end

    item:SetParentContainer(self)
    table.insert(self.Items, item)

    -- need syncronise with all
    self:SyncWithUser()
    return true
end

function ENT:RemoveItem(key)
    if type(key) == "entity" then
        local ent, key = key, nil
        
        for k, v in pairs(self.Items) do
            if v == ent then
                key = k
            end
        end

        if key then
            table.remove(self.Items, key)
            self:SyncWithUser()

            return true
        end
    
        return false
    else
        table.remove(self.Items, key)
        self:SyncWithUser()
        return true
    end
end

function ENT:UpdateItem(upd_ent, key)
    if key <= 0 then
        GS_MSG("Trying update item in cont, but ket is invalid")
        return
    end
    if upd_ent == nil then
        // removing item
        self:RemoveItem(key)
    else
        self.Items[key] = upd_ent
    end 
end

function ENT:CanBeOpened(user)
    // custom rewrite func
    // etc check if lock have lock or smthng
    return true
end
/*
function ENT:ItemInteraction(ent)
    print("cont", self, ent)
    return self:InsertItemInContainer(ent)
end
*/

function ENT:ThinkContainerCheck()
    // check current user (valid or )
    if CLIENT then return end
    if IsValid(self.UserContainer) then
        if self:GetPos():Distance(self.UserContainer:GetPos()) > 80 then
            self:CloseContainer(self.UserContainer)
        end
    end
end

function ENT:SyncWithUser()
    if !IsValid(self.UserContainer) then return end

    net.Start("gs_ent_container_open")
    net.WriteEntity(self)                    -- container - only for
    net.WriteTable(self:GetItems()) -- items
    net.Send(self.UserContainer)
end

function ENT:OpenContainer(ply)
    print(self, "close container", ply)
    if CLIENT then
        net.Start("gs_ent_container_open")
        net.WriteEntity(self)
        net.SendToServer()
    else
        if !self.IsContainer then return end
        if !player_manager.RunClass(ply, "CanOpenContainer") then return end // ply cant open container
        if !self:CanBeOpened(ply) then return end // some circumstances block open container

        ply.OpenedContainer = self
        self.UserContainer   = ply

        net.Start("gs_ent_container_open")
        net.WriteEntity(self)                    -- container - only for
        net.WriteTable(self:GetItems()) -- items
        net.Send(ply)
    end
end

function ENT:CloseContainer(ply, closeByPly)
    debug.Trace()
    if CLIENT then
        net.Start("gs_ent_container_close")
        net.WriteEntity(self)
        net.SendToServer()
    else
        if !closeByPly then
            net.Start("gs_ent_container_close")
            net.WriteEntity(self)
            net.Send(ply)
        end

        if IsValid(ply.OpenedContainer) then
            ply.OpenedContainer.UserContainer = nil
        end

        ply.OpenedContainer = nil
        //self.UserContainer = nil
    end
end

function ENT:DropFromInventary(dropEnt)
    --- force drop from cont
    --- it can be a ply or item container
end


---@alias userID integer The ID of a user

print(userID)

if CLIENT then return end
net.Receive("gs_ent_container_open", function(_, ply)
    local ent = net.ReadEntity()

    ent:OpenContainer(ply)
end)

net.Receive("gs_ent_container_close", function(_, ply)
    local ent = net.ReadEntity()

    ent:CloseContainer(ply, true)
end)
