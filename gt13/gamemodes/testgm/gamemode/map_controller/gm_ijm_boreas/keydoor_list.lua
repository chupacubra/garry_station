--MAP.keydoor_list = {}

DOOR_CIVILIAN = 1
DOOR_SERVICE  = 2
DOOR_MEDBAY   = 4
DOOR_CARGO    = 8


access_list = {
    
}



--[[
    the door status:
        0000
        ||||
        |||> open/close
        ||> jammed
        |>open/close service cectopn (wires)
        > BOLTED?
    
     
    [id] = {
        access = DOOR_CIVILIAN,
        stat = 0b0000
    }
    
]]

MAP.keydoor_list = {
    [1113] = {doors = {1109,1110}, access = DOOR_CIVILIAN}
}

MAP.buttons = {}
