local PLAYER = FindMetaTable("Player")

function PLAYER:IsGhost()
    -- check team
    -- and some check
end

function PLAYER:IsDead()
    -- check heavy is dead
    return GS_Round_System.DeadPlayers[self:SteamID()]
end

function PLAYER:SetDead()

end

function PLAYER:GS_GetName()
    -- getting name from Character data
    -- for papers
    local name = player_manager.RunClass( self, "GetGMName")
    if !name then
        GS_MSG("The player "..self:Nick().." don't have character name", MSG_WARNING)
        return ""
    end

    return name
end

function PLAYER:GS_GetNameFromID()
    -- getting name from ID, don't have -> false
end

function PLAYER:GS_GetAccess()
    -- get access from ID
end