GS_Round_System = {}

local PREP_TIME = 30
local ROUND_TIME = 500
local currentRound = 0
local roundsPlayed = 0


GS_Round_System.Round_Status = GS_ROUND_WAIT_PLY

function GS_Round_System:InitGame()
    -- when server (re)start
    GS_MSG("Start preparation round")
    
    self.Time         = CurTime()
    self.ReadyPly     = {}
    self.ObservePly   = {}
    self.DeadPlayers  = {}

    timer.Create( "RoundStatusTimer", 2, 0, function()
        self:UpdateClientStatus()
    end)

    self:StartPreparationPhase()
end

function GS_Round_System:UpdateClientStatus()
    net.Start("gs_round_status")
    net.WriteUInt(self.Round_Status, 3)
    net.WriteUInt(CurTime() - self.Time,16)
    net.Broadcast()
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
        print(ready,GS_PLY_Char:GetPlyChar(ply),"123" )
        if ready and GS_PLY_Char:GetPlyChar(ply) != nil then
            ply:SetTeam( TEAM_PLY )
            ply:UnSpectate()
            ply:Spawn()
            
            local char_tocken =  GS_PLY_Char:GetPlyChar(ply)
            ply:SetCharacter(char_tocken)
            print("spawn", ply)
            --player_manager.RunClass(ply, "SetCharacterData", char)
            --[[
                set plydata
                set job
                set antag
            ]]
        end
    end
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

    ply:SetTeam( TEAM_PLY )
    ply:UnSpectate()    
    ply:Spawn()

    local char =  GS_PLY_Char:GetPlyChar(ply)
    ply:SetCharacter(char)
    
    print("spawn", ply)



    --player_manager.RunClass(ply, "SetCharacterData", char)
end

function GS_Round_System:StartPreparationPhase()
    --game.SetTimeScale(0)-- Disable player movement
    
    GS_MSG("Start preparation round")
    self.Round_Status = GS_ROUND_PREPARE
    
    timer.Simple(PREP_TIME, function()
        self:StartRound()
    end)
end

function GS_Round_System:StartRound()
    --game.SetTimeScale(1)  -- Enable player movement
    self.Round_Status = GS_ROUND_RUNNING
    GS_MSG("Start round")

    self:StartRoundSpawnPlayer()
end

function GS_Round_System:EndRound()
    self.Round_Status = GS_ROUND_END

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
function GS_Round_System:PrestartRaffleJob()
    for k, v in pairs(self.ReadyPly) do
        local char = GS_PLY_Char:GetPlyChar(v)
        if char == false then
            GS_MSG(ply:Nick().."don't have char but ready and want to have a job")
            return
        end
    end
end

GS_Round_System:InitGame()