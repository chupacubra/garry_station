PLAYER_HANDS = {}
//obsolete?
function PLAYER_HANDS:SetupHandsMode()
    self:SetNWBool("CombatMode", false) 
end

function PLAYER_HANDS:HandsChangeMode()
    local v = !self:GetNWBool("CombatMode")
    self:SetNWBool("CombatMode", v)
    return v
end
