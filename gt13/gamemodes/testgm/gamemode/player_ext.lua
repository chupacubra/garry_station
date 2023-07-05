local PLAYER = FindMetaTable("Player")

function PLAYER:SetCharacter(tocken)
    self.Character_ID = tocken

    if !player_manager.GetPlayerClass(self) == "gs_human" then
        GS_MSG("The player have char but no class gs_human")
        return
    end

    PrintTable(GS_PLY_Char:GetChar(tocken))

    player_manager.RunClass(self, "SetCharacterData", GS_PLY_Char:GetChar(tocken))
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

function PLAYER:Examine(ply)
    local ex = player_manager.RunClass(self, "Examine")

    if !ex then
        GS_MSG("examine person, but no examine data! - "..tostring(ply))
        return
    end

    for k,v in pairs(ex) do
        ply:ChatPrint(v)
    end
end

-- tarakani begaut po hate
-- kupite dihlofoz