GS_PLY_Char = {}
GS_PLY_Char.Loaded = {}
GS_PLY_Char.CharSelect = {}
--net.Receive(, callback)

function GS_PLY_Char:SendToClientSucces(ply, bool)
	net.Start("gs_sys_char_send")
	net.WriteBool(bool)
	net.Send(ply)
end

function GS_PLY_Char:GetPlyChar(ply)
	local tocken = self.CharSelect[ply]
	return self.Loaded[tocken] or false
end

function GS_PLY_Char:SaveChar(ply, data)
	if !IsValid(ply) then
		return
	end

	if self.Loaded[ply] then
		if GS_Round_System:Status() != GS_ROUND_PREPARE and ply:Team() == TEAM_PLY  and ply:Alive() then
			GS_MSG(ply:Nick().." want to spawn but he is alive or already have char")
			return 
		end
	end

	local tocken = gentocken()

	data["unique_id"] = tocken
	
	self.Loaded[tocken] = data
	self:SelectChar(ply, tocken)

	self:SendToClientSucces(ply, true)
end

function GS_PLY_Char:SelectChar(ply, tocken)
	self.CharSelect[ply] = tocken
end

function GS_PLY_Char:HaveChar(ply)
	return self.CharSelect[ply] != nil
end

net.Receive("gs_sys_char_send", function(_, ply)
	local data = net.ReadTable()
end)