-- ENUM
-- The more I create enums, the more I think it's a sin
--
--
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

CHAT_COLOR = {
    RED = Color(204,0,0)
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
GS_ITEM_AMMO_PILE = 12
GS_ITEM_CHEM_CONTAINER = 13
GS_ITEM_COMMON = 14

FAST_EQ_TYPE = {
    "BACKPACK",
    "KEYCARD",
    "PDA",
    "BELT",
    "GLOVES",
    "VEST",
    "HEAD",
    "MASK",
    "EAR",--]]
}

FAST_HUD_TYPE = {
    BACKPACK = 1,
    KEYCARD  = 2,
    PDA      = 3,
    BELT     = 4,
    GLOVES   = 5,
    VEST     = 6,
    HEAD     = 7,
    MASK     = 8,
    EAR      = 9,
}

D_BRUTE = 1
D_BURN  = 2
D_TOXIN = 3
D_STAMINA = 4
REVERSE_DMG = {
    D_BRUTE = 1,
    D_BURN  = 2,
    D_TOXIN = 3,
    D_STAMINA = 4,
}

-- ammo for guns, 
AMMO_9MM       = 1
AMMO_9MM_R     = 2
AMMO_SHOTGUN   = 3
AMMO_SHOTGUN_R = 4
AMMO_SMG       = 5
AMMO_SMG_R     = 6 

REVERSE_AMMO = {
    AMMO_9MM       = 1,
    AMMO_9MM_R     = 2,
    AMMO_SHOTGUN   = 3,
    AMMO_SHOTGUN_R = 4,
    AMMO_SMG       = 5,
    AMMO_SMG_R     = 6,
}

GS_W_PISTOL = 1
GS_W_SMG     = 2
GS_W_SHOTGUN = 3
GS_W_RIFLE   = 4

GS_AW_MAGAZINE = 1
GS_AW_PUMP     = 2
GS_AW_BOLT     = 3

GS_BPART_HEAD      = 6
GS_BPART_BODY_TORS = 0
GS_BPART_L_HAND    = 14
GS_BPART_R_HAND    = 9
GS_BPART_R_LEG     = 18
GS_BPART_L_LEG     = 22

GS_HS_OK    = 1
GS_HS_CRIT  = 2
GS_HS_SHOCK = 3
GS_HS_UNCONSCIOUS = 4
GS_HS_STUN  = 5
GS_HS_DEAD  = 6

CONTEXT_WEAPON_SLOT = 1
CONTEXT_BACKPACK    = 2
CONTEXT_POCKET      = 3
CONTEXT_EQUIPMENT   = 4
CONTEXT_ITEM_IN_BACK = 5
CONTEXT_CONTAINER    = 6
CONTEXT_ITEM_IN_CONT = 7
CONTEXT_HAND = 8

-- if ITEM_SMALL then they fit in anywhere
-- if ITEM_MEDIUM then they don't fit in small box and pockets
-- if ITEM_BIG then they don't fit in backpacks
-- if ITEM_V_BIG then they don't fit in big box and can't handle

-- IDEA: How about CONTAINER_ITEM_MAX_SIZE?
-- For mega bluespace backpacks...

-- ITEM_V_MEDIUM for medium containers

ITEM_VERY_SMALL = 0
ITEM_SMALL  = 1
ITEM_MEDIUM = 2
ITEM_V_MEDIUM = 3
ITEM_BIG    = 4
ITEM_V_BIG  = 5


--[[
ENUM_D = {}
ENUM_D.enum = {}

function ENUM_D:ENUM(enm)
    return self.enum[enm] 
end

function ENUM_D:ENUM_Create(enm)
    if self.enum[enm] then
        return self.enum[enm]
    else
        self.enum[enm] = table.Count(enm)
        return self.enum[enm]
    end
end
--]]

GS_ROUND_WAIT_PLY = -1
GS_ROUND_PREPARE = 0
GS_ROUND_RUNNING = 1
GS_ROUND_END     = 2

T_SCREWDRIVER = 0
T_CROWBAR     = 1
T_WRENCH      = 2
T_HAMMER      = 3

CB_FLOOR      = 1
CB_HAND       = 2
CB_EQUIP      = 3


function roundstr(stat)
    if stat == GS_ROUND_WAIT_PLY then
        return "Wait some piple..."
    elseif stat == GS_ROUND_PREPARE then
        return "Preparing game"
    elseif stat == GS_ROUND_RUNNING then
        return "Game is running!"
    elseif stat == GS_ROUND_END then
        return "Game is end!"
    else
        return "..."
    end
end

function itemfrom(str)
    if str == "weap" then return CONTEXT_WEAPON_SLOT
    elseif str == "hand" then return CONTEXT_HAND
    elseif str == "backpack" then return CONTEXT_BACKPACK
    elseif str == "pocket" then return CONTEXT_POCKET
    elseif str == "equip" then return CONTEXT_EQUIPMENT
    elseif str == "item" then return CONTEXT_ITEM_IN_BACK
    elseif str == "container" then return CONTEXT_CONTAINER
    elseif str == "c_item" then return CONTEXT_ITEM_IN_CONT end
end

