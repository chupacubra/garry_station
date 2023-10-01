--[[
listen updates
]]
GS_RoundStatus = {}

function GS_RoundStatus:Init()
    self.Time = 0
    self.Round_Status = -1
end

function GS_RoundStatus:NetUpdateStatus(stat,time)
    self.Round_Status = stat
    self.Time         = time
    --PrintTable(self)
end

function GS_RoundStatus:GetRoundTime(nice)
    local time = CurTime() - GetGlobalInt("GameTime")

    if nice then
        local formt = formattime(string.FormattedTime(math.ceil(time)))
        return formt
    end

    return time
end

function GS_RoundStatus:GetRoundStatus()
    return GetGlobalInt("RoundStatus")
end

net.Receive("gs_round_status", function()
    local stat = net.ReadUInt(3)
    local time  = net.ReadUInt(16)
    GS_RoundStatus:NetUpdateStatus(stat,time)
end)