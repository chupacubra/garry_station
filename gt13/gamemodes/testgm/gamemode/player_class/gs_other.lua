PLAYER_OTHER = {}

local S_EXAMINE = 1
local s_EXAMINE_EQ = 2

function PLAYER_OTHER:MakeAction(ply, id)
    if id == S_EXAMINE then
        self:Examine(ply)
    end
end