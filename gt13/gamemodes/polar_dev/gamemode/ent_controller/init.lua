// ents controller
// creating and spawning

if SERVER then
    AddCSLuaFile("main.lua")
end

include("main.lua")

RegisterEnts()

GS_Ammo = {}

function RegisterAmmo(type, dmg)
    GS_Ammo[type] = dmg
end

function GetBulletDMG(type)
    return GS_Ammo[type]
end