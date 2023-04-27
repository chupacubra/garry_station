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
		origin = "predstart",
		owner = ply,
	}

	local tocken = gentocken()

	self.Chars[tocken] = pred_char
	
	if self.Selected_Chars[ply] then
		self:RemoveChar(self.Selected_Chars[ply])
	end

	self.Selected_Chars[ply] = tocken

	self:SendToClientSucces(ply, true)
end

function GS_PLY_Char:RemoveChar(tocken)
	self.Chars[tocken] = nil
end

function GS_PLY_Char:Name(tocken)
	if !self.Chars[tocken] then
		GS_MSG(tocken .." - the system don't have this character")
		return ""
	end
	local char = self.Chars[tocken]

	return char.character.name
end

function GS_PLY_Char:GetPlyChar(ply)
	local tocken = self.Selected_Chars[ply]

	if !tocken then
		return false
	end

	if !self.Chars[tocken] then
		GS_MSG(tostring(ply).." player loaded char but char is NOTHING!")
		return false
	end
	
	return tocken
end

function GS_PLY_Char:HaveChar(ply)
	local tocken = self.Selected_Chars[ply]
	if !tocken then
		return false
	end
	if !self.Chars[tocken] then
		GS_MSG(tostring(ply).." player loaded char but char is NOTHING!")
		return false
	end
	return tocken != false
end

function GS_PLY_Char:ChangeCharacter(ply, id)
	--[[
		cant change char while alive
		only if ghost or
	]]
end

function GS_PLY_Char:GetChar(tocken)
	if !self.Chars[tocken] then
		GS_MSG(tostring(tocken).." no loaded chars on this tocken")
		return {}
	end

	local char = self.Chars[tocken]

	return char["character"]
end


net.Receive("gs_sys_char_send", function(_, ply)
	local data = net.ReadTable()

	GS_PLY_Char:NewCharacter(ply, data)
end)