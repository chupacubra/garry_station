--[[
    этот системка нацелена на сбор инфы об игроках через компудахтеры и тд
    сбор таких данных как:
        рабочие станции(их статус, живые или нет)
        карго(текущии заказы и история)
        разная инфа по типу бюджета, кода, с
    

]]

GS_Info_DB = {}

function GS_Info_DB:Setup()
    local db = {}

    db.CrewmateDB = {} -- registered crewmates on station; name, status, job, notes
end

function GS_Info_DB:StartRoundRegisterCrewmate(ply, array)
    if !ply:IsValid() then 
        GS_MSG(tostring(ply) .." - invalid ply, cant register")    
        return
    end
    
    local crew = {}

    self.Crewmate[id] = 12
end
