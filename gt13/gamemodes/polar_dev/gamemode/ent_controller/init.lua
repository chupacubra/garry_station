// ents controller
// creating and spawning

if SERVER then
    AddCSLuaFile("main.lua")
end

include("ammo.lua")
include("main.lua")

RegisterEnts()

