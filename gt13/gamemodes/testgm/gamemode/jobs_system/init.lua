
if SERVER then
    include("cargo/init.lua")
    AddCSLuaFile("cargo/cl_init.lua")
else
    include("cargo/cl_init.lua")
end