if SERVER then
	include("gs_inventary.lua")
	include("gs_human_body.lua")
	include("gs_effects.lua")
	include("gs_char.lua")
end
DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.WalkSpeed = 200
PLAYER.RunSpeed  = 400
PLAYER.BaseWalkSpeed = PLAYER.WalkSpeed
PLAYER.BaseRunSpeed  = PLAYER.RunSpeed
PLAYER.UseVMHands = true
PLAYER.PLYModel  = "models/player/Group01/male_07.mdl"

function PLAYER:SetModel()
	local modelname = self.PLYModel

	util.PrecacheModel( modelname )
	self.Player:SetModel( modelname )
end

if SERVER then

	--INCLUDE INVENTARY FUNCTION
	for k,v in pairs(PLAYER_INVENTARY) do
		PLAYER[k] = v
	end

	--INCLUDE BODY AND HP FUNCTION
	for k,v in pairs(PLAYER_HP) do
		PLAYER[k] = v
	end

	--INCLUDE EFFECTS
	for k,v in pairs(PLAYER_EFFECT) do
		PLAYER[k] = v
	end

	--INCLUDE CHAR
	for k,v in pairs(PLAYER_CHAR) do
		PLAYER[k] = v
	end

end

function PLAYER:GetHandsModel()
	local playermodel = player_manager.TranslateToPlayerModelName( self.Player:GetModel() )
	return player_manager.TranslatePlayerHands( playermodel )
end

function PLAYER:SetupThink()
	timer.Create("gs_player_think_"..self.Player:EntIndex(), 1, 0, function()
		if !self.Player:IsValid() then
			self:StopThink()
			return
		end

		print('think player '..self.Player:GetName())
		
		local procent = math.random(1, 100)
		local dmg = self:GetSumDMG()
		

		if dmg >= 200 then -- death
			self:Death()
			self:HealthPartClientUpdate()

		elseif dmg >= 150 then --mega crit
			
			self.Player.HealthStatus = GS_HS_CRIT

			if procent <= 50 then
				self:CritParalyze(0,true)
				self:DamageHypoxia(4)
			end
			
			self:HealthPartClientUpdate() --softcrit

		elseif dmg >= 100 then

			self:EffectSpeedAdd("krit_status",-150, -250)
			self.Player.HealthStatus = GS_HS_CRIT
			
			if procent <= 40 then
				self:CritParalyze()
			end
			
			self:HealthPartClientUpdate()
		
		elseif dmg < 100 then
			if self.Player.HealthStatus != GS_HS_OK then
				self.Player.HealthStatus = GS_HS_OK
				self:HealthPartClientUpdate()
			end
		end

	end)

end

function PLAYER:StopThink()
	timer.Destroy("gs_player_think_"..self.Player:EntIndex())
end

function PLAYER:InitHudClient()
	net.Start("gs_cl_init_stat")
	net.WriteBool(true)
	net.Send(self.Player)
end

function PLAYER:CloseHudClient()
	net.Start("gs_cl_init_stat")
	net.WriteBool(false)
	net.Send(self.Player)
end

function PLAYER:SetupSystems()
	self:SetupInventary()
	self:SetupHPSystem()
	self:InitHudClient()
	self:SetupThink()
end

function PLAYER:Spawn()
	self:SetupSystems()
end



player_manager.RegisterClass( "gs_human", PLAYER, "player_default" )


net.Receive("gs_cl_inventary_request_backpack",function(_, ply) 
	player_manager.RunClass( ply, "SendToClientItemsFromBackpack" )
end)

net.Receive("gs_cl_inventary_use_weapon", function(_, ply)
	local from = net.ReadUInt(5)
	local key = net.ReadUInt(6)
	player_manager.RunClass( ply, "UseWeaponFromInventory", key, from)
end)

net.Receive("gs_cl_inventary_drop_ent", function(_, ply)
	local from = net.ReadUInt(5)
	local key = net.ReadUInt(6)
	player_manager.RunClass( ply, "DropEntFromInventary", key, from)
end)

net.Receive("gs_cl_weapon_drop", function(_, ply)
	local ent = net.ReadEntity()
	player_manager.RunClass( ply, "DropSWEP", ent )
end)

net.Receive("gs_cl_inventary_examine_item", function(_, ply)
	local from    = net.ReadUInt(5)
	local keyitem = net.ReadUInt(6)
	player_manager.RunClass( ply, "ExamineItemFromInventory", keyitem, from)
end)


net.Receive("gs_cl_contex_item_action", function(len, ply)
	local receiver = {}
	local drop     = {}

	receiver.entity = net.ReadEntity()
	receiver.key    = net.ReadUInt(6)
	receiver.from   = net.ReadUInt(5)

	drop.entity = net.ReadEntity()
	drop.key    = net.ReadUInt(6)
	drop.from   = net.ReadUInt(5)

	GS_MSG(ply:GetName().." make action on context menu")

	PrintTable(receiver)
	PrintTable(drop)
	player_manager.RunClass( ply, "MakeNormalContext", receiver, drop)
end)

net.Receive("gs_ent_container_close",function(_,ply)
	player_manager.RunClass( ply, "CloseEntContainer", true)
end)

net.Receive("gs_cl_actions_human", function(_, ply)
	local target = net.ReadEntity()
	local act    = net.ReadUInt(3)

	player_manager.RunClass(target, "MakeAction", ply, act)
end)