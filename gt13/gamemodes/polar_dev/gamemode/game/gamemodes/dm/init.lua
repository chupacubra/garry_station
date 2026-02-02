AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_derma.lua")

GS_GM = {}

GS_GM.Developer = true

function GS_GM:Init()
    GameRounds:Set(ROUND_RUN)
end
