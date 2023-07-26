--[[
    этот системка нацелена на сбор инфы об игроках через компудахтеры и тд
    сбор таких данных как:
        рабочие станции(их статус, живые или нет)
        карго(текущии заказы и история)
        разная инфа по типу бюджета, кода, с
    

]]

GS_Info_DB = {}

function GS_Info_DB:Setup()
--    local db = {}

    self.CrewmateDB = {} -- registered crewmates on station; name, status, job, notes
    self.Logs       = {} -- all action made by burecraty machines
end

function GS_Info_DB:RegisterCrewmate(ply, char)
    -- data = { name, job, id=tocken }

    if !ply:IsValid() then 
        GS_MSG(tostring(ply) .." - invalid ply, cant register")    
        return
    end
    
    local crew = {
        name = char.character.name,
        dna  = util.MD5( char.token ),
        job  = "UNDEFINED", -- nice job name
        status  = "ALIVE",
        warrant = "",
        warranted = false
    }

    self.CrewmateDB[char.token] = crew
end

function GS_Info_DB:RemoveCrewmate(token)
    -- can remove crewmate if only is exiting normal
    -- if dead - no action
    self.CrewmateDB[token] = nil
end

function GS_Info_DB:UpdateCrewField(token, field, value)
    self.CrewmateDB[token][field] = value

    table.insert(self.Logs, "UPDATE FIELD '"..tostring(field).."': "..tostring(value))
end

function GS_Info_DB:CrewChangeJob(token, job)
    self:UpdateCrewField(token, "job", job)
end

function GS_Info_DB:CrewWarranted(token, reason)

end

function GS_Info_DB:CrewUnwarrant(token)

end