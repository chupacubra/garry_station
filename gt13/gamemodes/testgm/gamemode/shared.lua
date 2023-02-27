include("player_class/gs_human.lua")

GM.Name = "GT13"
GM.Author = "N/A"
GM.Email = "N/A"
GM.Website = "N/A"

function GM:Initialize()
    --GS_Round_System:InitGame()
    --PrintTable(GS_Round_System)
end

team.SetUp( 1, "Player", Color(255,255,255))
team.SetUp( 2, "Ghost", Color(80,80,80))

TEAM_PLY = 1
