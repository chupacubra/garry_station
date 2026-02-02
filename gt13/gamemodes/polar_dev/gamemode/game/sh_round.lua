print("round system")

// необходима отдельная подгрузка режима (типо если дев то тольк он грузитца а другие нет)

GameRound = GameRound or {}

ROUND_NIL       = 0
ROUNT_PREPARE   = 1
ROUND_STARTED   = 2
ROUND_ENDED     = 3

function GameRound:Sync()
    // global vars
    SetGlobalInt("RoundType", self.RoundStatus)
    SetGlobalInt("RoundStart", self.RoundTime)
end

function GameRound:Get()
    return self.RoundStatus, self.RoundTime
end

function GameRound:Init()
    if self.Init then return end

    self.GM = gm
    self.Init = true

    self.RoundStatus = ROUND_NIL
    self.RoundTime = CurTime()
end

function GameRound:SetRoundStatus(r_stat)
    self.RoundStatus = r_stat
    self.Roundtime = CurTime()
    //self:Timer_Adjusting()

    self:Sync()
end

//adjust_func = function(GameRound self)
function GameRound:SetTimer(timer_id, adjust_func)
    //self.Timer = timer_id
    //self.Timer_Adjusting = adjust_func
end

function GameRound:Start()

end