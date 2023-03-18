-- make actions with ITEM DATA -
GS_EntityControler = GS_EntityControler or {}

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