local PLAYER = FindMetaTable("Player")
/*
function GM:PlayerSwitchWeapon( ply, oldwep, newwep )
	//return false
end
*/
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


function PLAYER:GetEquip(id)
	return player_managery.RunClass(self, "GetEquip", id)
end

// access check
function PLAYER:Keycard()
	return player_managery.RunClass(self, "GetEquip", "KEYCARD")
end

function PLAYER:GetAccess()
	local key = self:KeyCard()
	if !key then return 0 end // no access
	return key:GetAccess()
end

function PLAYER:HaveAccess(pad)
	local key = self:GetAccess()
	return Access.Can(pad, key)
end

function PLAYER:MakeTrace(len)
	return util.TraceLine({
		start = self:EyePos(),
		endpos = self:EyePos() + self:EyeAngles():Forward() * (len or 120),
		filter = self,
	})
end

function PLAYER:MakeViewTrace(len)
	local eye = self:GetAttachment(self:LookupAttachment("eyes"))
	local pos = eye.Pos


	debugoverlay.Line(pos, pos + self:EyeAngles():Forward() * (len or 120))

	return util.TraceLine({
		start = pos,
		endpos = pos + self:EyeAngles():Forward() * (len or 120),
		filter = self,
	})
end