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

function CalcSizeEnt(ent)
    // if weight > 40 then dont pickup 
    //
    // if ent is phys prop or need
    // 1. get obb max,min
    // 2. calc diag
    if IsValid(ent) then return ITEM_V_BIG end 
    local phys = ent:GetPhysicsObject()
    if !phys then return ITEM_V_BIG end

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

local LogColor = {
    i = MSG_INFO,
    w = MSG_WARNING,
    e = MSG_ERROR,
}

function GS_MSG(text)
    MsgC(MSG_INFO, "[GS] "..text.."\n")
end

function GS_Log(c, text)
    MsgC(c, "[GS] "..text.."\n")
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
    local clr = Color(0,255,0):Lerp(Color(255,0,0), int/100)
    return clr
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
    -- simple (but why so complicated...)
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


// i think for Notifys and another like-this shit need a separated file 
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

function ClGetWeaponsSlot(needEntity, ply)
    local arr = {}
    local allWeapons = ply:GetWeapons()

    if !needEntity then
        for i=1, #allWeapons do
            arr[i] = allWeapons[i]:GetPrintName()
        end
    else
        arr = ply:GetWeapons()
    end

    return arr
end

function PlyGetIDSWEP(wep, ply)
    local allwep = ClGetWeaponsSlot(true, ply)
    --local curwep = LocalPlayer():GetActiveWeapon()
    for k, v in pairs(allwep) do
        if v == wep then
            return k 
        end
    end
end

function GetSWEPFromID(id, ply)
    local allwep = ClGetWeaponsSlot(true, ply)
    --local curwep = LocalPlayer():GetActiveWeapon()
    return allwep[id]
end

function FromPhysicsBoneToPart(bone)
    local bone = self.Player:TranslatePhysBoneToBone(bone)
	while true do
		local isPart, part = getMainBodyPart(bone)
		if isPart then
			return part
		end
		bone = self.Player:GetBoneParent(bone)
	end
end

BonesNiceName = {
    skull = "skull",
    spine = "spine",
    l_arm = "left argm",
    r_arm = "right arm",
    l_leg = "left leg",
    r_leg = "right leg",
    ribs  = "ribs",
}
HitGroupPart = {
    [HITGROUP_GENERIC]    = "body",
    [HITGROUP_HEAD]       = "head",
    [HITGROUP_CHEST]      = "body",
    [HITGROUP_STOMACH]	  = "body",
    [HITGROUP_LEFTARM]	  = "hand_l",
    [HITGROUP_RIGHTARM]	  = "hand_r",
    [HITGROUP_LEFTLEG]	  = "leg_l",
    [HITGROUP_RIGHTLEG]   = "leg_r",
    [HITGROUP_GEAR]       = "body"
}

function FromHitGroupToPart(hg)
    return HitGroupPart[hg]
end

function tblsum(tbl)
    local n = 0
    for _, v in pairs(tbl) do
        n = n + v
    end
    return n
end

function GetHands(ply)
    local tbl = {}
    local s = ""
    for k, v in ipairs(ply:GetWeapons()) do
        s = v:GetClass()
        if s == "gs_hands_l" or s == "gs_hands_l" then tbl[#tbl+1] = v end
    end
    return tbl
end

function HandsFree(ply)
    local tbl = GetHands(ply)
    for k, v in ipairs(tbl) do
        if v:HaveItem() then return false end
    end
    return true
end

function getGameTimeStamp()
    -- ril lafe 2024
    -- gs13 teme 2024+28
    -- 2052-10-31 18:00:00
    local t = os.date("!*t")
    return tostring(t.year+28) .. "-" .. tostring(t.month) .. "-".. tostring(t.day) .. " " .. tostring(t.hour) ..":".. tostring(t.min) ..":".. tostring(t.sec)
end