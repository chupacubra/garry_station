-- ENUM
-- The more I create enums, the more I think it's a sin

//
// половина енумов уже не используется, это позор
//

//E_NIL = Entity(-1)

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


EQUIP_BACKPACK = 1
EQUIP_ID       = 2
EQUIP_PDA      = 3
EQUIP_BELT     = 4
EQUIP_EYES     = 5
EQUIP_VEST     = 6
EQUIP_HEAD     = 7
EQUIP_MASK     = 8
EQUIP_EAR      = 9
EQUIP_SUIT     = 10

-- next trash
--[[
GS_ENT_PROP     = 1
GS_ENT_MACHINE  = 2
GS_ENT_COMPUTER = 3

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

GS_BOARD_MACHINE = 1
GS_BOARD_COMPUTER = 2
--]]
FAST_EQ_TYPE = {
    "BACKPACK",
    "KEYCARD",
    "PDA",
    "BELT",
    "EYES",
    "VEST",
    "HEAD",
    "MASK",
    "EAR",
    "SUIT"
}

FAST_HUD_TYPE = {
    BACKPACK = 1,
    KEYCARD  = 2,
    PDA      = 3,
    BELT     = 4,
    EYES     = 5,
    VEST     = 6,
    HEAD     = 7,
    MASK     = 8,
    EAR      = 9,
}


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

CONTEXT_SWEP        = 1
CONTEXT_CONTAINER   = 2
CONTEXT_EQUIP       = 3
CONTEXT_POCKET      = 4



-- if ITEM_SMALL then they fit in anywhere
-- if ITEM_MEDIUM then they don't fit in small box and pockets
-- if ITEM_BIG then they don't fit in backpacks
-- if ITEM_V_BIG then they don't fit in big box and can't handle
-- ITEM_V_MEDIUM for medium containers

ITEM_VERY_SMALL = 0
ITEM_SMALL  = 1
ITEM_MEDIUM = 2
ITEM_V_MEDIUM = 3
ITEM_BIG    = 4
ITEM_V_BIG  = 5


ITEM_SIZE_TEXT = {
    [ITEM_VERY_SMALL]   = "very small",
    [ITEM_SMALL]        = "small",
    [ITEM_MEDIUM]       = "medium size",
    [ITEM_V_MEDIUM]     = "large size",
    [ITEM_BIG]          = "big",
    [ITEM_V_BIG]        = "very huge",
}

GS_ROUND_WAIT_PLY = -1
GS_ROUND_PREPARE = 0
GS_ROUND_RUNNING = 1
GS_ROUND_END     = 2
--[[
T_SCREWDRIVER = 0
T_CROWBAR     = 1
T_WRENCH      = 2
T_HAMMER      = 3
--]]
STATS_STR = {
    [GS_ROUND_WAIT_PLY] = "Wait some piple...",
    [GS_ROUND_PREPARE]  = "Preparing game",
    [GS_ROUND_RUNNING]  = "Game is running!",
    [GS_ROUND_END]      = "Game is end!",
}

function roundstr(stat)
    return STATS_STR[stat] or "..."
end
--[[
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
--]]
ITEM_FROM = {
    weap      = CONTEXT_WEAPON_SLOT,
    hand      = CONTEXT_HAND,
    backpack  = CONTEXT_BACKPACK,
    pocket    = CONTEXT_POCKET,
    equip     = CONTEXT_EQUIPMENT,
    item      = CONTEXT_ITEM_IN_BACK,
    container = CONTEXT_CONTAINER,
    c_item    = CONTEXT_ITEM_IN_CONT,
}

W_RED   = 1
W_GREEN = 2
W_BLUE  = 3
W_GOLD  = 4
W_GRAY  = 5
W_BLACK = 6
W_PINK  = 7
W_WHITE = 8

W_NAME = {
    "red",
    "green",
    "blue",
    "gold",
    "gray",
    "black",
    "pink",
    "white"
}

W_COLOR = {
    Color(240,20,20),
    Color(0,178,0),
    Color(0,0,153),
    Color(255,215,0),
    Color(128,128,128),
    Color(0,0,0),
    Color(255,151,187),
    Color(255,255,255),
}

W_CUT = 0
W_CONNECT = 1
W_PULSE = 2

A_EXAMINE = 0
A_USE     = 1

KS_MAINTANCE = 1
KS_BOLT      = 2
KS_BROKEN    = 3
KS_ROTATING  = 4

// next to DELETE
// now is some placeholder
JOB_LIST_DERMA = {
    ["Cargo Department"] = {
        --quartermaster = "Quartermaster",
        cargo_technician = "Cargo Technician",
    },

    ["Security"] = {
        sec_guard = "Security guard",
        --hos = "Head of Security",
    },

    ["Medical Department"] = {
        doctor = "Doctor",
        --cmo = "Chief Medical Officer",
    },

    ["Research Department"] = {
        scientist = "Scientist",
    },

    ["Engineers"] = {
        technician = "Technician"
    },

    ["Control Department"] = {
        station_master = "Station Master"
    }
}

S_EXAMINE    = 1 -- exam ply
s_EXAMINE_EQ = 2 -- exam eq
S_EXAMINE_BD = 3 -- exam body
S_ACT_EQ     = 4 -- action with eq

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

GS_DMG_LIST = {
    [DMG_GENERIC]        = D_BRUTE,
    [DMG_CRUSH]	         = D_BRUTE,
    [DMG_BULLET]	     = D_BRUTE,	
    [DMG_SLASH]	         = D_BRUTE,
    [DMG_BURN]	         = D_BURN,
    [DMG_VEHICLE]	     = D_BRUTE,
    [DMG_FALL]	         = D_BRUTE,	
    [DMG_BLAST]	         = D_BRUTE,
    [DMG_CLUB]	         = D_BRUTE,
    [DMG_SHOCK]	         = D_BURN,
    [DMG_SONIC]	         = D_BRUTE,
    [DMG_ENERGYBEAM]     = D_BURN,	
    --[DMG_PREVENT_PHYSICS_FORCE	2048	
    [DMG_NEVERGIB]       = D_BRUTE,	
    [DMG_ALWAYSGIB]      = D_BRUTE,
    --DMG_DROWN =
    [DMG_PARALYZE]       = D_TOXIN,
    [DMG_NERVEGAS]       = D_TOXIN,	
    [DMG_POISON]	     = D_TOXIN,
    [DMG_RADIATION]      = D_TOXIN,
    --DMG_DROWNRECOVER = 	
    [DMG_ACID]           = D_TOXIN,
    [DMG_SLOWBURN]       = D_BURN,
    --DMG_REMOVENORAGDOLL	4194304	
    [DMG_PHYSGUN]        = D_BRUTE,
    [DMG_PLASMA]         = D_BURN,
    [DMG_AIRBOAT]        = D_BRUTE,	
    --DMG_DISSOLVE	67108864	
    --DMG_BLAST_SURFACE	134217728	
    --DMG_DIRECT	268435456	
    [DMG_BUCKSHOT]       = D_BRUTE,
    [DMG_SNIPER]         = D_BRUTE,
    [DMG_MISSILEDEFENSE] = D_BRUTE,	
}

MAP_DMG = {
    [DMG_SHOCK]	         = D_BURN,
    [DMG_BURN]	         = D_BURN,
    [DMG_SONIC]	         = D_BRUTE,
    [DMG_ENERGYBEAM]     = D_BURN,
    [DMG_ACID]           = D_TOXIN,
    [DMG_SLOWBURN]       = D_BURN,
    [DMG_PARALYZE]       = D_TOXIN,
    [DMG_NERVEGAS]       = D_TOXIN,	
    [DMG_POISON]	     = D_TOXIN,
    [DMG_RADIATION]      = D_TOXIN,
}

ARMORY_PART = {
    head   = {"HEAD", "MASK"},
    hand_l = {"SUIT"},
    hand_r = {"SUIT"},
    body   = {"VEST", "SUIT"},
    leg_l  = {"SUIT"},
    leg_r  = {"SUIT"},
}

