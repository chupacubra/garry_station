local PLAYER = FindMetaTable("Player")

function PLAYER:SetCharacter(tocken)
    self.Character_ID = tocken
end

function PLAYER:GetCharacter()
    return self.Character_ID or false
end

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
    local name = GS_PLY_Char:Name(self:GetCharacter())

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

function PLAYER:Examine()
    local name = self:GS_GetName()

    if !name then
        return
    end

    return "It's a "..name.."!"
end