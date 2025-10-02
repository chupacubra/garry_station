// ents controller
// creating and spawning

if SERVER then
    AddCSLuaFile("main.lua")
    include("ammo.lua")
end

include("main.lua")

RegisterEnts()

