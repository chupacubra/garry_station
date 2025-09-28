local PLAYER = FindMetaTable("Player")

function PLAYER:SetupDataTables()
	self.Player:NetworkVar( "String", 0, "Name" )

	self:SetName(self:Nick())
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

function PLAYER:RunClass(func, ...)
	print(self, func, ... )
	//PrintTable(args)
	print(args)
	return player_manager.RunClass(self, func, ...)
end

function PLAYER:GetExamineData()
	if CLIENT then return end
	local exam = {}
	
	print(player_manager.GetPlayerClass(self))

	table.insert(exam, "{255 255 255}It's a "..self:GetName())
	table.Add(exam, self:RunClass("GetExamineData" ))

	return exam
end

//function PLAYER:ServerContextMenuCallback()

function PLAYER:GetContextButtons(args)
	local buttons = {}

	buttons["Examine"] = {
        name = "Examine",
        //func = func,
		func = function()
			//self:RunCallback()
			self:Examine()
		end,
        icon = "icon16/eye.png",
    }
	
	return buttons
end

function PLAYER:Examine(ply)
	if CLIENT then 
		net.Start("gs_examine_ply")
		net.WritePlayer(self)
		net.SendToServer()
		return
	end
	local exam = self:GetExamineData()
	local exam_str = table.concat(exam, "\n")
	
	RichTextPrint(exam_str, ply)
end

function PLAYER:IsGhost()
    -- check team
    -- and some check
    return self:Team() == TEAM_GHOST
end

function PLAYER:IsActive()
    // can player use something, pickup something 
    // if player is sleep or in ragdoll
    return self:Team() == TEAM_PLY and player_manager.GetPlayerClass(self) == "gs_human"
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

function PLAYER:MakeViewTrace(len, dir)
	local eye = self:GetAttachment(self:LookupAttachment("eyes"))
	local pos = eye.Pos

	debugoverlay.Line(pos, pos + self:EyeAngles():Forward() * (len or 120))
	if dir then
		return util.TraceLine({
			start = pos,
			endpos = pos + dir,
			filter = self,
		})
	else
		return util.TraceLine({
			start = pos,
			endpos = pos + self:EyeAngles():Forward() * (len or 120),
			filter = self,
		})
	end
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

net.Receive("gs_examine_ply", function(_, ply)
	local target = net.ReadPlayer()

	target:Examine(ply)
end)