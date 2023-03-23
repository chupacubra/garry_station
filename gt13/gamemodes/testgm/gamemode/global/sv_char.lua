GS_PLY_Char = {}
GS_PLY_Char.Loaded = {}

--net.Receive(, callback)

function GS_PLY_Char:SendToClientSucces(ply, bool)
	net.Start("gs_sys_char_send")
	net.WriteBool(bool)
	net.Send(ply)
end

function GS_PLY_Char:GetPlyChar(ply)
	return self.Loaded[ply] or false
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

	data["unique_id"] = gentocken()

	self.Loaded[ply] = data
	self:SendToClientSucces(ply, true)
end

net.Receive("gs_sys_char_send", function(_, ply)
	local data = net.ReadTable()
end)