DeriveGamemode("sandbox")

if SERVER then
    AddCSLuaFile("player_class/gs_human.lua")
end
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
//TEAM_SPEC = TEAM_SPECTATOR

function GM:CreateTeams()
    team.SetUp( TEAM_PLY, "Player", Color(255,255,255))
    team.SetUp( TEAM_SPECTATOR, "Ghost", Color(80,80,80))
end