// some hint
// "физический" перенос предмета в другой на себя берёт получающий контейнер (SetParentContainer)
// при удалении предмета из первого же удалит только из таблицы

ENT.IsContainer = false
ENT.MaxItems    = 6
ENT.ItemMaxSize = ITEM_MEDIUM

function ENT:GetContainerItems()
    return self.Items
end

function ENT:GetContainerItem(key)
    if !self.IsContainer then return end

    return self.Items[key]
end

function ENT:SetContainerItems(tbl)
    if !self.IsContainer then return end

    self.Items = tbl
end

function ENT:InsertItemInContainer(item)
    if !self.IsContainer then return end

    if table.Count(self.Items) + 1 > self.MaxItems then
        return false
    end

    if self.ItemMaxSize < item.Size then
		self.ContainerUser:ChatPrint(item.Name.." is not fit in "..self.Name)
		return false
	end

    item:SetParentContainer(self)
    table.insert(self.Items, item)

    //player_manager.RunClass( self.ContainerUser, "OpenEntContainer", self)
    -- need syncronise with all
    return self:GetContainerItems()
end

function ENT:RemoveItem(key)
    table.remove(self.Items, key)
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

function ENT:ItemInteraction(ent)
    return self:InsertItemInContainer(ent)
end

function ENT:ThinkContainerCheck()
    // check current user (valid or )
    if self.UserContainer:IsValid() then
        if self:GetPos():Distance(self.UserContainer:GetPos()) > 80 then
            //PlyCloseContainer(self, self.UserContainer)
            ContainerUserClose(self)
        end
    end
end

// functions for items

function ENT:DropFromInventary()
    // force drop from cont
    // it can be a ply or item container
end

// controling, open 
// warnigng: only 1 ply can use in one time container

function ClPlySendContainer(ent, ply)
    net.Start("gs_ent_container_open")
    net.WriteEntity(ent)                    -- container - only for
    net.WriteTable(ent:GetContainerItems()) -- items
    net.Send(ply)
end

function PlyOpenContainer(ent, ply)
    if !player_manager.RunClass(ply, "CanOpenContainer") then return end // ply cant open container
    if !ent:CanBeOpened(ply) then return end // some circumstances block open container

    ply.OpenedContainer = ent
    ent.UserContainer   = ply

    ClPlySendContainer(ent, ply)
end

function PlyCloseContainer(ply)
    net.Start("gs_ent_container_close")
    net.Send(ply)

    if IsValid(ply.OpenedContainer) then
        ply.OpenedContainer.UserContainer = nil
    end

    ply.OpenedContainer = nil
end

function ContainerUserClose(ent)
    if IsValid(ent.UserContainer) then
        net.Start("gs_ent_container_close")
        net.Send(ent.UserContainer)
    end

    ent.UserContainer.OpenedContainer = nil
    ply.OpenedContainer = nil
end

