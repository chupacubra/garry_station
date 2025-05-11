function GM:PlayerSwitchWeapon( ply, oldwep, newwep )
	return false
end

function InHandsItem(ply, class)
	local c
	for _, w in ipairs(ply:GetWeapons()) do
		c = w:GetClass()
		if w.IsHands then
			if !w:GetItem() then continue end
			c = w:GetItem():GetClass()
		end
		if c == class then return true end
	end
	return false
end
