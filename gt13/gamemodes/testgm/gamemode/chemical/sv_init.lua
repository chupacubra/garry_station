include("chemical_main.lua")
include("chemical_list_base.lua")

if SERVER then
	for k,v in pairs(CHEMICALS) do
		for kk,vv in pairs(RECEIPTS) do
			if RECEIPTS[kk]["inp"][k] then
				if !FAST_REC[k] then FAST_REC[k] = {} end
				FAST_REC[k][kk] = true
			end
		end
	end

	local cl_chem = {}
	for k,v in pairs(CHEMICALS) do
		if v["notdispense"] != true then
			cl_chem[k] = v["normalName"]
		end
	end

	timer.Simple( 5, function()
		net.Start("gs_sys_chem_list")
			local int = tonumber(list_length(cl_chem))
			net.WriteInt(int,10)
			for k,v in pairs(cl_chem) do
				net.WriteString(k.."/"..v)
			end
		net.Broadcast()
	end)

	PrintTable(CHEMIC)
	PrintTable(FAST_REC)
end