PLAYER_CHAR = {}
--[[
	класс не должен отвечать за хранение данных о персонаже, это будут делать остальные системы
]]
function PLAYER_CHAR:SetCharacterData(char)
	--[[
		Setup chararcter in spawn
		char get from client
		generate spec uniq ID
		
		char = {
			name = "John Jonson",
			model = "modelstring",
			model_id = 9,
			...
		}
	]]

	self.Character = char
	print("apply?")
	PrintTable(self.Character)
end

function PLAYER_CHAR:GetCharName()
	return self.Character.name
end

function PLAYER_CHAR:Examine(ply)
	--[[
		RETURN
			name
			examine_data (if have)
			equipments
			active swep or hand item

		in future:
			name IF have keycard or if you REMEMBER this person
			--examine_data
	]]
	--return self.Character.name
	local examine = {}

	table.insert(examine, "It's a "..self.Character.name.."!")

	for k, v in pairs(examine) do
		ply:ChatPrint(v)
	end
end
