// ents controller
// creating and spawning

if SERVER then
    AddCSLuaFile("main.lua")
    AddCSLuaFile("ammo.lua")
end

include("main.lua")
include("ammo.lua")

RegisterEnts()

