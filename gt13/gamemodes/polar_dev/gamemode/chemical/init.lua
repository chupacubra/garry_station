// loader for chemicals
if SERVER then
    AddCSLuaFile("chemical_main.lua")
    AddCSLuaFile("chemical_list_base.lua")
    AddCSLuaFile("chemical_list_food.lua")
    AddCSLuaFile("chemical_list_drink.lua")
    AddCSLuaFile("chemical_list_med.lua")
end

include("chemical_main.lua")
include("chemical_list_base.lua")
include("chemical_list_food.lua")
include("chemical_list_drink.lua")
include("chemical_list_med.lua")

for k,v in pairs(CHEMICALS) do
	for kk,vv in pairs(RECEIPTS) do
		if RECEIPTS[kk]["inp"][k] then
			if !FAST_REC[k] then FAST_REC[k] = {} end
			FAST_REC[k][kk] = true
		end
	end
end