GS_ClPlyStat = {}
GS_ClPlyStat.init = false

--[[
    Receive the health stats,
    Receive update of inventory

    Send update of inventory

    initialize
]]
  
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

function GS_ClPlyStat:EquipItem(name, typ)
    self.equipment[FAST_EQ_TYPE[typ]] = name
    
    if typ == GS_EQUIP_BACKPACK then
        ContextMenu:DrawBackpackButton()
    end

    ContextMenu:UpdateEquipmentItem()
end

function GS_ClPlyStat:InitInventory()
    self.equipment = {
            BELT      = 0, 
            GLOVES    = 0, 
            KEYCARD   = 0, 
            PDA       = 0,
            BACKPACK  = 0,
            VEST      = 0,
            HEAD      = 0,
            MASK      = 0,
            EAR       = 0,
    }

    self.pocket = {{},{}}
end

function GS_ClPlyStat:GetEquipName(key)
    if self.equipment[key] == nil or self.equipment[key] == 0 then
        return ""
    end

    return self.equipment[key]
end

function GS_ClPlyStat:UpdateHP(hp, part, parthp, iconstat)
    print(iconstat)
    if part != "0" then
        self.hp[part] = parthp
    end

    self.iconhp = hp
    self.icon_stat = iconstat
end

function GS_ClPlyStat:GetWeaponsSlot(needEntity)
    local arr = {}
    local allWeapons = LocalPlayer():GetWeapons()

    if !needEntity then
        for i=1, #allWeapons do
            arr[i] = allWeapons[i]:GetPrintName()
        end
    else
        arr = LocalPlayer():GetWeapons()
    end

    return arr
end

function GS_ClPlyStat:HaveEquip(key)
    return self.equipment[key] != 0
end

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
    net.Start("gs_cl_weapon_drop")
    net.WriteEntity(entity)
    net.SendToServer()
end

function GS_ClPlyStat:ExamineData(examinedata)
    for k,v in pairs(examinedata) do
        if k == 1 then
            v = "It is ".. v
        end
        LocalPlayer():ChatPrint(v)
    end
end

function GS_ClPlyStat:GetItemFromPocket(key)
    return self.pocket[key]
end

function GS_ClPlyStat:GetNameItemFromPocket(key)
    return self.pocket[key]["Name"] or ""
end


function GS_ClPlyStat:GetItemFromPockets()
    return self.pocket
end

function GS_ClPlyStat:UpdatePockets(items)
    self.pocket = items
    --PrintTable(self.pocket)
    --print(self.pocket[1]["Name"])
end
 
function GS_ClPlyStat:UpdateInventoryItems(items, from)
    if from == CONTEXT_POCKET then
        self:UpdatePockets(items)
    elseif from == CONTEXT_BACKPACK then
        ContextMenu:UpdateInventoryItems(items)
    end
end
--[[
function GS_ClPlyStat:CloseContainer()
    net.Start()
end
--]]
--[[
function GS_ClPlyStat:OpenContainer(items)

end
--]]


function GS_ClPlyStat:ClientCloseContainer()
    net.Start("gs_ent_container_close")
    net.SendToServer()
end

function GS_ClPlyStat:SendActionToServer(rec,drp)
    PrintTable(drp)
    local item_1, item_2, entity_1, entity_2, from1, from2
    
    item_1, entity_1 = typeRet(rec.item)
    item_2, entity_2 = typeRet(drp.item)

    from1 = itemfrom(rec.type)
    from2 = itemfrom(drp.type)

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
        GS_ClPlyStat:DeathStatus()
    end
end)

net.Receive("gs_equipment_update",function()
    local key = net.ReadUInt(5)
    local itemName = net.ReadString()

    GS_ClPlyStat:EquipItem(itemName, key)
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
    local items = net.ReadTable()
    ContextMenu:OpenContainer(items)
end)

net.Receive("gs_ent_container_close",function()
    ContextMenu:CloseContainer()
end)