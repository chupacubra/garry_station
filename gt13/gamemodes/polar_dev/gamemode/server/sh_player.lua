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

function PLAYER:RunClass(...)
	return player_manager.RunClass(ply, unpack(args))
end

function PLAYER:IsGhost()
    -- check team
    -- and some check
    return self:Team() == TEAM_GHOST
end

function PLAYER:IsActive()
    // can player use something, pickup something
    // if player is sleep or in ragdoll
    return self:Team() == TEAM_PLY and player_manager.GetPlayerClass( self ) == "gs_human"
end
/*
function PLAYER:Think()
	print("123")
	ply:RunClass("Think")
end
*/
function PLAYER:GetEquip(id)
	return player_managery.RunClass(self, "GetEquip", id)
end

// access check
function PLAYER:Keycard()
	return player_managery.RunClass(self, "GetEquip", "KEYCARD")
end

function PLAYER:GetAccess()
	local key = self:KeyCard()
	//if !key then return 0 end // no access
	if key then
		return key:GetAccess()
	end

	local swep = ply:GetActiveWeapon()
	if swep.IsHands then
		local item = item:GetItem()
		if item.IsKeycard then
			return item:GetAccess()
		end
	end
	return 0
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

local stamina_to_run = 50

hook.Add("Move", "PlayerMove", function(ply, mv)
	if !ply:IsActive() then return end
	
	local origSpeed = mv:GetMaxSpeed()
	local origClientSpeed = mv:GetMaxClientSpeed()
	
	local stamina = ply:GetLocalNWVar("Stamina")
	if !stamina then return end

	if stamina < stamina_to_run then
		mv:SetMaxSpeed(origSpeed * 0.5)
		mv:SetMaxClientSpeed(origClientSpeed * 0.5)
	end

	if mv:KeyDown(IN_SPEED) then
		if stamina > stamina_to_run then
			stamina = stamina - FrameTime() * 5
			if SERVER then
				ply.Organism_Value.stamina = stamina
			end
			ply:SetLocalNWVar("Stamina", stamina)
		end
		ply.LastInSpeed = CurTime()
	end

end)