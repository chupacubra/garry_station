GS_PLY_Char = {}
GS_PLY_Char.Chars = {}
GS_PLY_Char.Selected_Chars = {}

--[[
	IDEA:
		система должна отвечать за регистрацию и смену игроками персонажей
		если игрок загружает персонажа в предстартовом меню, то мы ег
]]


function GS_PLY_Char:SendToClientSucces(ply, bool)
	net.Start("gs_sys_char_send")
	net.WriteBool(bool)
	net.Send(ply)
end

function GS_PLY_Char:AddPredstartCharacter(ply, c_data)

	-- validate character
	--[[
		predstart_character = {
			data = {
				name,
				model,
				examine_data,
			}
			job_setting = {
				job_current,
				job_wanted,
			},
			antag_setting = {
				antag_current,
				antag_wanted,
			},
			origin = "predstart_char",
			owner = ply,
		}
	]]
	
	if !c_data.name or !c_data.model then
		return
	end

	local token = gentocken()

	local pred_char = {
		character = {
			name = c_data.name,
			model = c_data.model,
			examine_data = c_data.examine_info,
		},
		job_setting = {
			current = false,
			wanted  = c_data.job_prefer,
		},
		antag_setting = {
			current = false
		},
		db_info = {
			p_notes = c_data.person_notes,
		},
		token = token,
		origin = "predstart",
		owner = ply,
	}

	self.Chars[token] = pred_char
	
	if self.Selected_Chars[ply] then
		self:RemoveChar(self.Selected_Chars[ply])
	end

	self.Selected_Chars[ply] = token

	self:SendToClientSucces(ply, true)
end

function GS_PLY_Char:RemoveChar(token)
	self.Chars[token] = nil
end

function GS_PLY_Char:Name(token)
	if !self.Chars[token] then
		GS_MSG(token .." - the system don't have this character")
		return ""
	end
	local char = self.Chars[token]

	return char.character.name
end

function GS_PLY_Char:GetPlyChar(ply)
	local token = self.Selected_Chars[ply]

	if !token then
		return false
	end

	if !self.Chars[token] then
		GS_MSG(tostring(ply).." player loaded char but char is NOTHING!")
		return false
	end
	
	return token
end

function GS_PLY_Char:HaveChar(ply)
	local token = self.Selected_Chars[ply]
	if !token then
		return false
	end
	if !self.Chars[token] then
		GS_MSG(tostring(ply).." player loaded char but char is NOTHING!")
		return false
	end
	return token != false
end

function GS_PLY_Char:ChangeCharacter(ply, id)
	--[[
		cant change char while alive
		only if ghost or
	]]
end

function GS_PLY_Char:GetChar(token)
	if !self.Chars[token] then
		GS_MSG(tostring(token).." no loaded chars on this token")
		return {}
	end

	local char = self.Chars[token]

	return char["character"]
end

function GS_PLY_Char:GetCharData(token)
	if !self.Chars[token] then
		GS_MSG(tostring(token).." no loaded chars on this token")
		return {}
	end

	local char = self.Chars[token]

	return char
end

function GS_PLY_Char:UpdateCharData(token, char)
	if !self.Chars[token] then
		GS_MSG(tostring(token).." no loaded chars on this token")
		return {}
	end

	self.Chars[token] = char
	GS_MSG("UPDATED CHAR FOR "..token)
	PrintTable(self.Chars)
end

function GS_PLY_Char:SendPlyData(ply)
	local char = self:GetCharData(self:GetPlyChar(ply))
	if !char then
		GS_MSG(tostring(ply).." - want to send to client info but him char is nil")
	end
	-- send ply:
	-- name
	-- job, and antag

	//net.Start()
end

net.Receive("gs_sys_char_send", function(_, ply)
	local data = net.ReadTable()

	GS_PLY_Char:NewCharacter(ply, data)
end)