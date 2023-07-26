-- make actions with ITEM DATA -
GS_EntityControler = GS_EntityControler or {}
--[[
    need make this to

    GS_EntityControler:CreateActionItem("item1", "item2", function(item1, item2, ply)
        print("connecting item1 with item2")
        CreateTask(function()
            connecting succesful!
        end)
    end)
 
]]
function GS_EntityControler:MakeActionEntData(receiver, drop)
    if receiver.Entity_Data.ENUM_Type == GS_ITEM_AMMO_MAGAZINE and (drop.Entity_Data.ENUM_Type == GS_ITEM_AMMOBOX or drop.Entity_Data.ENUM_Type == GS_ITEM_MATERIAL) then
        if cantype(receiver.Entity_Data.ENUM_Subtype, drop.Entity_Data.ENUM_Subtype) then
            return self:InsertAmmoInMagazine(receiver, drop)
        end
    end
    return false
end

function GS_EntityControler:InsertAmmoInMagazine(receiver, drop)
    print("inserting ammo in magazine")
    if receiver.Private_Data.Bullets == receiver.Private_Data.Max_Bullets then
        return
    end

    local ammoinbox = drop.Private_Data.Stack or drop.Private_Data.AmmoInBox
    if ammoinbox == 0 then
        return
    end
    
    if drop.Private_Data.Stack then
        drop.Private_Data.Stack = drop.Private_Data.Stack - 1
    else
        drop.Private_Data.AmmoInBox = drop.Private_Data.AmmoInBox - 1
    end
    
    local bullet = drop.Private_Data.BulletDamage
    table.insert(receiver.Private_Data.Magazine, bullet)

    receiver.Private_Data.Bullets = receiver.Private_Data.Bullets + 1
    
    local chat_rez = "You inserted a bullet in "..receiver.Entity_Data.Name
    
    return receiver, drop, chat_rez
end

function GS_EntityControler:ExamineData(ent)
    local arr = {}
    
    for k,v in pairs(ent.Examine_Data) do
        local str = v.examine_string
        local arg = {}
        for k,v in pairs(v.arguments) do
            arg[k] = self[v[1]][v[2]]
        end
        arr[k] = string.format(str, unpack(arg))
    end

    return arr
end

function GS_EntityControler.ItemInBoardReceipt(board, part)
    if board.Private_Data.Parts[part.Entity_Data.ENT_Name] != nil then
        return true, board.Private_Data.Parts[part.Entity_Data.ENT_Name]
    end
    return false, 0
end

function GS_EntityControler.InsertInENTItem(ent, typ, name)

end

function GS_EntityControler:MakeEntData(typ, id)
    -- make entity, after copy entity, then delete
    -- cringe
    local ent = GS_EntityControler:MakeEntity(id, typ, Vector(0,0,0))

    local ent_data = duplicator.CopyEntTable(ent)

    ent:Remove()

    return ent_data
end

--[[
    array = {
        equipment = {
            BACKPACK = {
                id  = simple_backpack,
                typ = backpack
                contain = {
                    {},
                    {},
                }
            }
        }
        pockets   = {
            {},
            {}
        }
    }
]]

function GS_EntityControler.GiveItemFromArray(ply, array)
    if !ply:IsValid() then
        return
    end

    local function getContain(item_contain)
        local itemData_contain = GS_EntityControler:MakeEntData(item_contain.typ, item_contain.id)

        if item_contain.contain then
            local contain_contain_item = {}

            for k, v in pairs(item_contain.contain) do
                table.insert(contain_contain_item, getContain(v))
            end

            for k, v in pairs(contain_contain_item) do
                table.insert(itemData_contain.Private_Data.Items, v)
            end
        end

        return itemData_contain
    end

    for key, item in pairs(array.equipment) do
        local itemData = GS_EntityControler:MakeEntData(item.typ, item.id)
        
        if item.contain then
            local contain_item = {}

            for k, v in pairs(item.contain) do
                table.insert(contain_item, getContain(v))
            end

            for k, v in pairs(contain_item) do
                table.insert(itemData.Private_Data.Items, v)
            end
        end

        player_manager.RunClass( ply, "EquipItem", itemData, key)
    end

    if array.pockets then
        for pocket, item in pairs(array.pockets) do
            -- don't use contain because box don't fit in pocket
            local itemData = GS_EntityControler:MakeEntData(item.typ, item.id)

            if !itemData then
                continue
            end

            player_manager.RunClass( ply, "InsertItemInPocket", itemData, pocket)
        end
    end
end