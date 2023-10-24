GS_Round_System = {}

local PREP_TIME = 30
local ROUND_TIME = 500

GS_Round_System.Round_Status = GS_ROUND_WAIT_PLY

function GS_Round_System:InitGame()
    -- when server start
    GS_MSG("Start preparation round")
    
    self.Time         = CurTime()
    self.ReadyPly     = {}
    self.ObservePly   = {}
    self.DeadPlayers  = {}

    local succes = gs_map.load()
    
    if succes then
        self:StartPreparationPhase()
    end
end

function GS_Round_System:UpdateClientStatus()
    SetGlobalInt("RoundStatus", self.Round_Status)
end

function GS_Round_System:GetRoundTime(nice)
    local time = CurTime() - self.Time

    if nice then
        local formt = formattime(string.FormattedTime(math.ceil(time)))
        return formt
    end

    return time
end

function GS_Round_System:Status()
    return self.Round_Status
end

function GS_Round_System:PlayerReady(ply,ready)
    print(ply,ready)
    if self.Round_Status != GS_ROUND_PREPARE then 
        return false
    end

    --[[
        only ply who have char can be ready
    ]]
    --print(GS_PLY_Char:HaveChar(ply), !GS_PLY_Char:HaveChar(ply))
    if !GS_PLY_Char:HaveChar(ply) then
        GS_MSG("WTF player don't have char and want to READY!?!?")
        return false
    end

    self.ReadyPly[ply] = ready
    return true
end

function GS_Round_System:PlayerObserver(ply,ready)

end

function GS_Round_System:StartRoundSpawnPlayer()
    for ply,ready in pairs(self.ReadyPly) do
        if ready and GS_PLY_Char:GetPlyChar(ply) != nil then
            ply:SetTeam( TEAM_PLY )
            ply:UnSpectate()
            ply:Spawn()

            --local pos = gs_map.get_spawn_pos(wanted_job)

            --ply:SetPos(gs_map.get_spawn_pos(wanted_job))
            
            local char_token = GS_PLY_Char:GetPlyChar(ply)

            ply:SetCharacter(char_token)
            local char_data = GS_PLY_Char:GetCharData(char_token)
            GS_Job:GiveJobItem(ply, char_data.job_setting.current)

            print("spawn", ply)
        end
    end
end

function GS_Round_System:PlySpawn(ply, char)

end

function GS_Round_System:RoundSpawnPlayer(ply)
    if ply:Team() != TEAM_SPECTATOR then
        GS_MSG("player want to spawn, when he team != spectator")
        return
    end

    if self:Status() != GS_ROUND_RUNNING then
        GS_MSG("player want to spawn, when round != running")
        return
    end

    local char = GS_PLY_Char:GetPlyChar(ply)
    
    if char == false then
        GS_MSG("player want to spawn, when round != running")
        ply:ChatPrint("Load char first!")
        return
    end


    local char_data   = GS_PLY_Char:GetCharData(char)

    GS_Info_DB:RegisterCrewmate(ply, char_data)

    local wanted_job = char_data.job_setting.wanted[1]

    --print("14134erewr",wanted_job)

    if wanted_job == "" then
        wanted_job = "cargo_technician"
    end

    char_data.job_setting.current = wanted_job

    GS_PLY_Char:UpdateCharData(token, char_data)
    
    GS_Job:GivePlyJob(ply, wanted_job)

    ply:SetTeam( TEAM_PLY )
    ply:UnSpectate()    
    ply:Spawn()

    --local pos = gs_map.get_spawn_pos(wanted_job)
    --print(pos)
    --ply:SetPos(gs_map.get_spawn_pos(wanted_job)) 

    local char = GS_PLY_Char:GetPlyChar(ply)
    ply:SetCharacter(char)
    
    GS_Job:GiveJobItem(ply, wanted_job)

    print("spawn", ply)

    --player_manager.RunClass(ply, "SetCharacterData", char)
end

function GS_Round_System:StartPreparationPhase()
    --game.SetTimeScale(0)-- Disable player movement
    
    GS_MSG("Start preparation round")

    GS_Info_DB:Setup()
    
    self.Round_Status = GS_ROUND_PREPARE
    
    self:UpdateClientStatus()

    timer.Simple(PREP_TIME, function()
        self:StartRound()
        self:UpdateClientStatus()
    end) 
end

function GS_Round_System:StartRound()
    --game.SetTimeScale(1)  -- Enable player movement
    self.Round_Status = GS_ROUND_RUNNING
    GS_MSG("Start round")

    for ply, ready in pairs(self.ReadyPly) do
        local char_tocken = GS_PLY_Char:GetPlyChar(ply)
        local char_data   = GS_PLY_Char:GetCharData(char_tocken)

        GS_Info_DB:RegisterCrewmate(ply, char_data)
    end

    self:RaffleJob()

    self:StartRoundSpawnPlayer()
end

function GS_Round_System:EndRound()
    self.Round_Status = GS_ROUND_END
    self:UpdateClientStatus()

    timer.Simple(30, function() 
        self:EndMatch() 
    end)
end

function GS_Round_System:EndMatch()
    -- Restart the map
    game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
end

function GS_Round_System:AddDeadPly(plyID)
    if self.DeadPlayers[plyID] then
        GS_MSG(plyID.." is already dead!")
        return
    end
 
    self.DeadPlayers[plyID] = true
end

function GS_Round_System:RemoveDeadPly(plyID)
    if !self.DeadPlayers[plyID] then
        GS_MSG(plyID.." isnt dead!")
        return
    end

    self.DeadPlayers[plyID] = nil
end


--[[
    randomise job for char use char seetings
    
    char.job_preference -> char.job_selected
    if job_preference = nil:
        char.job_selected = random job

]]

function GS_Round_System:RaffleJob()
    -- before spawning
    print("ALE ALE ALE")
    for ply, ready in RandomPairs(self.ReadyPly) do
        
        --[[if !ready then
            continue
        end
        --]]

        local token = GS_PLY_Char:GetPlyChar(ply)
        
        if !token then
            GS_MSG(ply:Nick().."don't have char but ready and want to have a job")
            return
        end

        local char = GS_PLY_Char:GetCharData(token)

        local wanted_job = char.job_setting.wanted[1]
        
        if wanted_job == "" then
            -- give random job
        end

        char.job_setting.current = wanted_job
        -- give wanted job

        GS_Job:GivePlyJob(ply, wanted_job)
        
        GS_PLY_Char:UpdateCharData(token, char)
        debug.Trace()
    end
end
