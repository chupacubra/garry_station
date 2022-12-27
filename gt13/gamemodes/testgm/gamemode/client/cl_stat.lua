GS_ClPlyStat = {}
GS_ClPlyStat.init = false

--[[
    Receive the health stats,
    Receive update of inventory

    Send update of inventory

    initialize
]]
  
function GS_ClPlyStat:Initialize()
    self.player     = LocalPlayer()
    --self.modelID    = 1 --[[ the ID of basics model (these faces(?)) ]]
    self.round_data = {}
    self.antag      = false
    self.hp         = self:InitHP()

    self:InitInventory()
    --self:GetStartRoundItemsTEST()
    --PrintTable(self)
    self.init = true

end


function GS_ClPlyStat:InitHP()
    --[[
    net.start()
    hp = net.Read()
    --]]
    local BODY = {
		head   = 100,
		hand_l = 100,
		hand_r = 100,
		body   = 100,
		leg_l  = 100,
		leg_r  = 100,
	}
    return BODY

end



function GS_ClPlyStat:RequestItemsFromBackpack()
    if self.equipment.BACKPACK == 0 then
        return {}
    end

    net.Start("gs_cl_inventary_request_backpack")
    net.SendToServer()
end


function GS_ClPlyStat:EquipItem(data)
    if data.ENUM_Subtype == nil then
        return false
    end

    if self.equipment[FAST_EQ_TYPE[data.ENUM_Subtype]] == 0 then
       self.equipment[FAST_EQ_TYPE[data.ENUM_Subtype]] = data
    end

    PrintTable(self.equipment)
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
end

function GS_ClPlyStat:GetNameItem(tocken)
    if self.allitems[tocken] != nil then
        return self.allitems[tocken]["name"]
    end
    return "unk"
end

function GS_ClPlyStat:GetEquipName(key)
    if self.equipment[key] == nil then
        return "nil"
    end

    return self.equipment[key]["Name"]
end

function GS_ClPlyStat:UpdateHP()
--[[
    if we get a pain
    ]]
    return {
		head   = {100}, 
		hand_l = {100},
		hand_r = {100},
		body   = {100},
		leg_l  = {100},
		leg_r  = {100},
	}
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

function GS_ClPlyStat:UseWeaponFromInventary(key)
    net.Start("gs_cl_inventary_use_weapon")
    net.WriteInt(key, 8)
    net.SendToServer()
end

function GS_ClPlyStat:DropEntFromInventary(key)
    net.Start("gs_cl_inventary_drop_ent")
    net.WriteInt(key, 8)
    net.SendToServer()
end

function GS_ClPlyStat:DropSWEP(entity)
    net.Start("gs_cl_weapon_drop")
    net.WriteEntity(entity)
    net.SendToServer()
end

function GS_ClPlyStat:MoveSWEPToBackpack(entity)
    net.Start("gs_cl_weapon_move_inventary")
    net.WriteEntity(entity)
    net.SendToServer()
end

PrintTable(GS_ClPlyStat)

--input.SelectWeapon( LocalPlayer():GetWeapons())

net.Receive("gs_equipment_update",function()
    local key = net.ReadInt(8)
    local itemData = net.ReadTable()

    GS_ClPlyStat:EquipItem(itemData)
end)

net.Receive("gs_cl_inventary_request_backpack",function() --??????????????
    local items = net.ReadTable()
    PrintTable(items)
    ContextMenu:OpenBackpack(items)
end)

net.Receive("gs_cl_init_stat", function()
    local bool = net.ReadBool()
    GS_ClPlyStat:Initialize()
end )

net.Receive("gs_cl_inventary_update", function()
    local items = net.ReadTable()
    ContextMenu:UpdateInventoryItems(items)
end)