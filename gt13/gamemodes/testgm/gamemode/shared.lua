include("player_class/gs_human.lua")

GM.Name = "GT13"
GM.Author = "N/A"
GM.Email = "N/A"
GM.Website = "N/A"

function GM:Initialize()
    --GS_Round_System:InitGame()
    --PrintTable(GS_Round_System)
end

TEAM_PLY = 1
TEAM_SPEC = TEAM_SPECTATOR

function GM:CreateTeams()
    team.SetUp( TEAM_PLY, "Player", Color(255,255,255))
    team.SetUp( TEAM_SPEC, "Ghost", Color(80,80,80))
end

function getGameTimeStamp()
    -- ril lafe 2024
    -- gs13 teme 2024+28
    -- 2052-10-31 18:00:00
    local t = os.date("!*t")
    return tostring(t.year+28) .. "-" .. tostring(t.month) .. "-".. tostring(t.day) .. " " .. tostring(t.hour) ..":".. tostring(t.min) ..":".. tostring(t.sec)
end