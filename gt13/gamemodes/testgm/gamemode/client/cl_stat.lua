GS_ClPlyStat = GS_ClPlyStat or {}
--GS_ClPlyStat.init = false

--[[
    Receive the health stats,
    Receive update of inventory
    Send update of inventory

    initialize
]]
  

/*
    need to divide funcs
*/

function GS_ClPlyStat:Initialize()
    self:InitHP()
    self:InitInventory()
    self.init = true
end

function GS_ClPlyStat:InitHP()
    self.hp = {
		head   = 100,
		hand_l = 100,
		hand_r = 100,
		body   = 100,
		leg_l  = 100,
		leg_r  = 100,
	}
    
    self.iconhp = 1
    self.hunger = 100
    self.hungerColor = hungerColor(self.hunger)
    self.icon_stat = GS_HS_OK

    GS_Notes:Init()
end

function GS_ClPlyStat:GetHPStatIcon()
    if self.icon_stat == GS_HS_CRIT then
        return 7
    end
    return self.iconhp
end

function GS_ClPlyStat:RequestItemsFromBackpack()
    if self.equipment.BACKPACK == 0 then
        return {}
    end

    net.Start("gs_cl_inventary_request_backpack")
    net.SendToServer()
end

function GS_ClPlyStat:InitInventory()
    self.equipment = {
        BELT      = nil, 
        EYES      = nil, 
        KEYCARD   = nil, 
        PDA       = nil,
        BACKPACK  = nil,
        VEST      = nil,
        HEAD      = nil,
        MASK      = nil,
        EAR       = nil,
    }

    //self.equipment_class = {} -- for saving class of equip item
    self.pocket = {}
end

function GS_ClPlyStat:EquipItem(item, typ, class)
    self.equipment[typ] = item 

    if typ == GS_EQUIP_BACKPACK then
        ContextMenu:DrawBackpackButton()
    end

    ContextMenu:UpdateEquipmentItem()
end

function GS_ClPlyStat:RemoveEquip(key)
    self.equipment[key] = 0

    ContextMenu:UpdateEquipmentItem()
end

function GS_ClPlyStat:GetEquipName(key)
    if self.equipment[key] == nil or self.equipment[key] == 0 then
        return ""
    end

    return self.equipment[key]["Name"]
end

function GS_ClPlyStat:GetEquipItem(key)
    //if self.equipment[key] == nil or self.equipment[key] == 0 then
    //    return false
    //end

    return self.equipment[key] or nil
end

function GS_ClPlyStat:UpdateHP(hp, part, parthp, iconstat)
    --print(iconstat)
    if part != "0" then
        self.hp[part] = parthp
    end

    self.iconhp = hp
    self.icon_stat = iconstat
    self.cur_weap = 1
end

function GS_ClPlyStat:SetCurrentWeaponsSlot()
    local allWeapons = LocalPlayer():GetWeapons()
    local cur = LocalPlayer():GetWeapons()

    for i=1, #allWeapons do
        if allWeapons[i] == cur then
            return i
        end
    end

end

function GS_ClPlyStat:GetCurrentWeaponsSlot()
    return self.cur_weap
end

function GS_ClPlyStat:HaveEquip(key)
    return self.equipment[key] != 0
end

--[[
function GS_ClPlyStat:UseWeaponFromInventary(key, from)
    net.Start("gs_cl_inventary_use_weapon")
    net.WriteUInt(from, 5)
    net.WriteUInt(key, 6)
    net.SendToServer()
end

function GS_ClPlyStat:DropEntFromInventary(key, from)
    net.Start("gs_cl_inventary_drop_ent")
    net.WriteUInt(from, 5)
    net.WriteUInt(key, 6)
    net.SendToServer()
end

function GS_ClPlyStat:DropSWEP(entity)
    -- need get id
    local id = PlyGetIDSWEP(entity, LocalPlayer())
    LocalPlayer():ConCommand("gs_dropswep "..tostring(id))
    SelectWep(1)
end
--]]

function GS_ClPlyStat:GetItemFromPocket(key)
    return self.pocket[key] or nil
end

--function GS_ClPlyStat:GetNameItemFromPocket(key)
--    return self.pocket[key]["Name"] or ""
--end

function GS_ClPlyStat:GetItemFromPockets()
    return self.pocket
end

function GS_ClPlyStat:UpdatePockets(items)
    self.pocket = items
    if ContextMenu.Open then
        ContextMenu:UpdatePockets()
    end
end

function GS_ClPlyStat:UpdateInventoryItems(items, from)
    if from == CONTEXT_POCKET then
        self:UpdatePockets(items)
    elseif from == CONTEXT_BACKPACK then
        ContextMenu:UpdateInventoryItems(items)
    end
end

function GS_ClPlyStat:DeEquipItem(key)
    net.Start("gs_equipment_update")
    net.WriteUInt(key, 5)
    net.SendToServer()
end

--[[
function GS_ClPlyStat:SendActionToServer(rec,drp)
    local item_1, item_2, entity_1, entity_2, from1, from2
    
    item_1, entity_1 = typeRet(rec.item)
    item_2, entity_2 = typeRet(drp.item)

    from1 = ITEM_FROM[rec.type]
    from2 = ITEM_FROM[drp.type]

    print(from1,from2)

    net.Start("gs_cl_contex_item_action")

    net.WriteEntity(entity_1 or Entity(0))
    net.WriteUInt(item_1 or 0, 6)
    net.WriteUInt(from1, 5)

    net.WriteEntity(entity_2 or Entity(0))
    net.WriteUInt(item_2 or 0, 6)
    net.WriteUInt(from2, 5)

    net.SendToServer()
end
--]]

function GS_ClPlyStat:DeathStatus()
    self.init = false
end

function GS_ClPlyStat:HungerStatus()
    return self.hunger
end

function GS_ClPlyStat:HungerColor()
    return self.hungerColor
end

function GS_ClPlyStat:HungerSet(int)
    self.hunger = int
    self.hungerColor = hungerColor(int)
end



function DropItem(item)
    // drop item from slots (equip, item, pocket, container)
    // neeed thinkinh!
    /*
    net.Start("gs_item_drop")
    net.WriteUInt(from)
    net.WriteUInt(key)
    net.WriteEntity(item)
    */
end

function OpenContainer(item)
    net.Start("gs_ent_container_open")
    net.WriteEntity(item)
    net.SendToServer()
end

function CloseContainer()
    net.Start("gs_ent_container_close")
    net.SendToServer()
end

function SendActionToServer(rec,drp)
    -- not sending ents, send slots
    // from = container, equip, pocket, swep
    // id
    //local item_1, entity_1 = typeRet(rec.item)
    //local item_2, entity_2 = typeRet(drp.item)

    //local from1 = ITEM_FROM[rec.type]
    //local from2 = ITEM_FROM[drp.type]

    net.Start("gs_cl_context_item_action")

    net.WriteUInt(rec.from or 0, 6)
    net.WriteUInt(rec.key, 5)

    net.WriteUInt(drp.from or 0, 6)
    net.WriteUInt(drp.key, 5)

    net.SendToServer()
end

net.Receive("gs_ply_hunger", function()
    local hunger = net.ReadUInt(7)

    GS_ClPlyStat:HungerSet(hunger)

    print(hunger)
end)

net.Receive("gs_cl_init_stat", function()
    local bool = net.ReadBool()
    if bool then
        GS_ClPlyStat:Initialize()
    else
        -- need some hooks?
        GS_ClPlyStat:DeathStatus()
    end
end)

net.Receive("gs_equipment_update",function()
    local key = net.ReadUInt(5)
    local bool = net.ReadBool()
    if bool then
        local class = net.ReadString()
        local item = scripted_ents.Get(class).Entity_Data
        GS_ClPlyStat:EquipItem(item, key, class)
    else
        GS_ClPlyStat:RemoveEquip(key)
    end
end)

net.Receive("gs_cl_inventary_update", function()
    local from  = net.ReadUInt(5)
    local items = net.ReadTable()
    GS_ClPlyStat:UpdateInventoryItems(items, from)
end)

net.Receive("gs_cl_inventary_examine_return", function()
    local examine = net.ReadTable()
    GS_ClPlyStat:ExamineData(examine)
end)

net.Receive("gs_health_update",function()
    local part = net.ReadString()
    local parthp = net.ReadInt(8)
    local iconhp =  net.ReadUInt(5)
    local iconstat = net.ReadUInt(5)
    GS_ClPlyStat:UpdateHP(iconhp, part, parthp, iconstat)
end)

net.Receive("gs_ent_container_open", function()
    local cont  = net.ReadEntity()
    local items = net.ReadTable()

    ContextMenu:OpenContainer(items, cont)
end)

net.Receive("gs_ent_container_close",function()
    ContextMenu:CloseContainer()
end)

