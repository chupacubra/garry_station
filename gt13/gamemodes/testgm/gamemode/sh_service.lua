local list = {1,2,3,4,5,6,7,8,9,"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
function gentocken()
    local str = "" 
    while string.len(str) != 4 do
        local int = math.random(1, #list)
        str = str .. list[int]
    end
    return str
end

function getMainBodyPart(bone) -- hardcode
    if bone == GS_BPART_BODY_TORS then
        return true, "body"
    elseif bone ==  GS_BPART_HEAD then
        return true, "head"
    elseif bone == GS_BPART_L_HAND then
        return true, "hand_l"
    elseif bone == GS_BPART_R_HAND then
        return true, "hand_r"
    elseif bone == GS_BPART_L_LEG then
        return true, "leg_l"
    elseif bone == GS_BPART_R_LEG then
        return true, "leg_r"
    end
    return false
end

function cantype(receiver, typ)
    if type(receiver) == "table" then
        for k,v in pairs(receiver) do
            if typ == v then
                return true
            end
        end
        return false
    else
        return receiver == typ
    end
end

MSG_ERROR = Color( 255, 25, 25 )
MSG_WARNING = Color( 255, 251, 132)
MSG_INFO = Color( 66,170,255)

function GS_MSG(text,color)
    MsgC(MSG_INFO, "[GS] "..text.."\n")
end

function typeRet(item)
    if type(item) == "number" then
        return item, nil
    end
    return nil, item
end

function ItemType(item)
    return item.Entity_Data.ENUM_Type
end

function ItemSubType(item)
    return item.Entity_Data.ENUM_Subtype
end

function FQT(item)
    return FAST_EQ_TYPE[item.Entity_Data.ENUM_Subtype]
end

function FitInContainer(maxsize, drp )
    if drp.ENUM_Type == GS_ITEM_CONTAINER  or (drp.ENUM_Type == GS_ITEM_EQUIP and drp.ENUM_Type == GS_EQUIP_BACKPACK) then
        return maxsize > drp.Size
    else
        return maxsize + 1 > drp.Size
    end
end

function formattime(time)
    return string.format("%02d:%02d:%02d", time.h,time.m,time.s)
end

function haveNegativeVals(tbl_ints)
    return math.min(unpack(tbl_ints) or 0) < 0
end

function tbl_get_from_index(tbl, ind)
    local rez = {}

    for k, v in pairs(tbl) do
        table.insert(rez,v[ind])
    end

    --PrintTable(rez)
    --print("123123")
    return rez
end

function hungerColor(int)
    --[[
        100 - 0,200,0
        75  - 100,200,0
        50  - 200,200,0
        25  - 200,100,0
        0   - 200,0,0
    ]]

    if int == 100 then
        return Color(0,200,0,255)
    end

    if int > 50 then
        local red = (100 - int) * 4

        return Color(red, 200, 0, 255)
    else
        local green = int * 4

        return Color(200, green, 0, 255)
    end
end

function table_max(tbl)
    local m = 0
    for k,v in pairs(tbl) do
        m = math.max(m, v)
    end

    return m
end

function table_min(tbl)
    local m = tbl[1]

    for k,v in pairs(tbl) do
        m = math.min(m, v)
    end

    return m
end

function flipcoin()
    return math.random(1, 2) == 1
end

function flipquart()
    return math.random(1, 4) == 1
end

function PrintBones( entity )
    for i = 0, entity:GetBoneCount() - 1 do
        print( i, entity:GetBoneName( i ) )
    end
end

function generateID(str)
    -- simple
    -- 1. rand_str = str + number day of the year(365)
    -- 2. rez = util.SHA1(rand_str)
    -- 3. strip all letters
    -- 4. stay only 5 digits
    -- 5. ???
    -- 6. !!!profit!!!

    local rand_str = str .. os.date("%j")
    local rez = util.SHA1(rand_str)
    
    rez = string.gsub(rez, "%a", "")
    rez = string.Left(rez, 5)

    return rez
end

if CLIENT then
    net.Receive("gs_cl_show_notify", function()
        local title = net.ReadString()
        local msg   = net.ReadString()

        Derma_Message(title, msg, "OK")
    end)
else
    function ShowNotify(ply, title, msg) -- title, message
        net.Start("gs_cl_show_notify")
        net.WriteString(title)
        net.WriteString(msg)
        net.Send(ply)
    end
end

function Entity_SetNWData(ent, tab)
    for k, v in pairs(tab) do
        local typ = type(v)
        if typ == "number" then
            ent:SetNWInt(k, v, 10)
        elseif typ == "string" then
            ent:SetNWString(k, v)
        else
            print("watafak mazafak", typ)
        end
    end
end