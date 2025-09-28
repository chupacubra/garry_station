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
    // some shit?
    if !LUA_FILES_LOADED or self.Init then return end
   
    self.Init = true
    
end

TEAM_PLY = 1
//TEAM_SPEC = TEAM_SPECTATOR

function GM:CreateTeams()
    team.SetUp( TEAM_PLY, "Player", Color(255,255,255))
    team.SetUp( TEAM_SPECTATOR, "Ghost", Color(80,80,80))
end