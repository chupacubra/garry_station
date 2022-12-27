-- ENUM

GS_HUD_100 = 1
GS_HUD_75  = 2
GS_HUD_50  = 3
GS_HUD_25  = 4
GS_HUD_0   = 5 


HUD_COLOR = {
    Color(50,205,50),
    Color(163,255,102),
    Color(237,255,33),
    Color(175,43,30),
}

function GetProcentColor(num)
    if num == 100 then
        return HUD_COLOR[1]
    elseif num > 75 then
        return HUD_COLOR[2]
    elseif num > 40 then
        return HUD_COLOR[3]
    else
        return HUD_COLOR[4]
    end
end

GS_EQUIP_BACKPACK = 1
GS_EQUIP_ID       = 2
GS_EQUIP_PDA      = 3
GS_EQUIP_BELT     = 4
GS_EQUIP_GLOVES   = 5
GS_EQUIP_VEST     = 6
GS_EQUIP_HEAD     = 7
GS_EQUIP_MASK     = 8
GS_EQUIP_EAR      = 9

GS_ITEM_PROP = 1
GS_ITEM_MATERIAL = 2
GS_ITEM_AMMOBOX = 3
GS_ITEM_AMMO_MAGAZINE = 4
GS_ITEM_FOOD = 5
GS_ITEM_CONTAINER = 6
GS_ITEM_BOX = 7
GS_ITEM_BOARD = 8
GS_ITEM_PART = 9
GS_ITEM_WEAPON = 10 
GS_ITEM_EQUIP = 11

FAST_EQ_TYPE = {
    "BACKPACK",
    "KEYCARD",
    "PDA",
    --[[
    BELT
    GLOVES
    PDA
    VEST
    HEAD
    MASK
    EAR--]]
}

FAST_HUD_TYPE = {
    BACKPACK = 1,
    KEYCARD  = 2,
    PDA      = 3,
}

D_BRUTE = 1
D_BURN  = 2
D_TOXIN = 3
D_STAMINA = 4

-- ammo for guns, 
AMMO_9MM       =  1
AMMO_9MM_R     = 2
AMMO_SHOTGUN   = 3
AMMO_SHOTGUN_R = 4
AMMO_SMG       = 5
AMMO_SMG_R     = 6 

GS_W_PISTOL = 1
GS_W_SMG = 2
GS_W_SHOTGUN = 3

GS_AW_MAGAZINE = 1
GS_AW_PUMP     = 2
GS_AW_BOLT     = 3

GS_BPART_HEAD     = 6
GS_BPART_BODY_TORS = 0
GS_BPART_L_HAND    = 14
GS_BPART_R_HAND    = 9
GS_BPART_R_LEG     = 18
GS_BPART_L_LEG     = 22
