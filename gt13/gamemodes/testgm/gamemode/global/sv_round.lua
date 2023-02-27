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
    if self.Round_Status != GS_ROUND_PREPARE then 
        return
    end

    self.ReadyPly[ply] = ready
end

function GS_Round_System:PlayerObserver(ply,ready)

end

function GS_Round_System:StartRoundSpawnPlayer()
    for ply,ready in pairs(self.ReadyPly) do
        if ready then
            ply:SetTeam( TEAM_PLY )
            ply:UnSpectate()
            ply:Spawn()
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
    
    ply:SetTeam( TEAM_PLY )
    ply:UnSpectate()
    ply:Spawn()
    --
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

GS_Round_System:InitGame() 