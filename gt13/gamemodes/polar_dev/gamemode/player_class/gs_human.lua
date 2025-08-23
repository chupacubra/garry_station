if SERVER then
	AddCSLuaFile("gs_inventary.lua")

	include("gs_inventary.lua")
	include("gs_human_body_new.lua")
	include("gs_human_body_organs.lua")
	include("gs_effects.lua")
	include("gs_char.lua")

	//AddCSLuaFile("gs_cl_equipment.lua")
else
	include("gs_inventary.lua")
	//include("gs_cl_equipment.lua")
end


DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.WalkSpeed = 200
PLAYER.RunSpeed  = 400
PLAYER.BaseWalkSpeed = PLAYER.WalkSpeed
PLAYER.BaseRunSpeed  = PLAYER.RunSpeed
PLAYER.UseVMHands = true
PLAYER.PLYModel  = "models/player/Group01/male_07.mdl"


if SERVER then
	table.Merge(PLAYER, PLAYER_INVENTARY)
	table.Merge(PLAYER, PLAYER_HP)
	table.Merge(PLAYER, PLAYER_ORGANS)
	table.Merge(PLAYER, PLAYER_EFFECT)
	table.Merge(PLAYER, PLAYER_CHAR)
else

	table.Merge(PLAYER, PLAYER_INVENTARY)

end

local function RunOnClient(ply, fun, broad)
	net.Start("gs_cl_runOnClient")
	net.WritePlayer(ply)
	net.WriteString(fun)
	
	if broad then
		net.Broadcast()
	else
		net.Send(ply)
	end
end

function PLAYER:SetModel(name)
	local modelname = name or PlayerModel()
	
	util.PrecacheModel( modelname )
	self.Player:SetModel( modelname )

	self.Player:SetupHands()
end


function PLAYER:GetHandsModel()
	local playermodel = player_manager.TranslateToPlayerModelName( self.Player:GetModel() )
	return player_manager.TranslatePlayerHands( playermodel )
end

function PLAYER:StopThink()
	local i = self.Player:EntIndex()
	timer.Destroy("gs_player_think_"..i)
	timer.Destroy("gs_bleed"..i)
	timer.Destroy("gs_hunger_"..i)
	timer.Destroy("gs_organs_think_"..i)
end


function PLAYER:InitClientState()
	if SERVER then
		net.Start("gs_cl_init_stat")
		net.WritePlayer(self.Player)
		net.WriteBool(true)
		net.Broadcast()
	else
		self:SetupInventary()
	end
end

function PLAYER:SetupSystems()
	self:SetupInventary()
	self:SetupHPSystem()
	//self:InitClientState()
end

function PLAYER:Spawn()
	self:SetupSystems()
	if !self.FirstSpawn then
		timer.Simple(1, function()
			self:InitClientState()
		end)
	else
		self:InitClientState()
	end

	self.FirstSpawn = true
end

function GS_EquipWeapon(ply, weapon) -- for start loadout
	local ent = ents.Create(weapon)
	ply:PickupWeapon( ent )
	if weapon == "gs_swep_hand" then
		timer.Simple(0.5, function()
			ent:SetHoldType("normal")
		end)
	end
end

function PLAYER:Loadout()
    self.Player:StripAmmo()
    self.Player:StripWeapons()

	GS_EquipWeapon(self.Player, "gs_hands_l")
	GS_EquipWeapon(self.Player, "gs_hands_r")
end

local dev = GetConVar( "developer")

function PLAYER:BodyDebugPrint()
	if !dev:GetBool() then return end

	if true then return end
	-- show debug with body status
	-- need show:
	-- Organism_Value
	-- organs hp
	-- body parts hp

	// NASRALI

	local debug_print = {"--------------DEBUG----------------"}

	for i=2, 20 do
		debug_print[i] = "|"
	end

	table.insert(debug_print,"--------------DEBUG----------------")

	local i = 2

	for k, v in pairs(self.Player.Organism_Value) do
		if type(v) == "table" then
			debug_print[i] = debug_print[i]..stringspacer("", 20)
			i = i + 1
			for kk, vv in pairs(v) do
				local vv = tostring(vv)
				debug_print[i] = debug_print[i]..stringspacer(" "..k.."."..kk..": "..vv, 20)
				i = i + 1
			end
			debug_print[i] = debug_print[i]..stringspacer("", 20)
			i = i + 1
			continue
		end
		local v = tostring(v)
		debug_print[i] = debug_print[i]..stringspacer(" "..k..": "..v, 20)

		i = i + 1
	end
	
	i = 2

	for k, v in pairs(self.Player.Organs) do
		if type(v) == "table" then
			i = i + 1
			for kk, vv in pairs(v) do
				local vv = tostring(vv)
				debug_print[i] = debug_print[i]..stringspacer("| "..k.."."..kk..": "..vv, 20)
				i = i + 1
			end
			debug_print[i] = debug_print[i]..stringspacer("|", 20)
			i = i + 1
			continue
		end
		local v = tostring(v)
		debug_print[i] =  debug_print[i]..stringspacer("| "..k..": "..v, 20)

		i = i + 1
	end
	debug_print[i] = debug_print[i]..stringspacer("|", 20)
	i = i + 1

	for k, v in pairs(self.Player.Bones) do
		if type(v) == "table" then
			i = i + 1
			for kk, vv in pairs(v) do
				local vv = tostring(vv)
				debug_print[i] = debug_print[i]..stringspacer("| "..k.."."..kk..": "..vv, 20)
				i = i + 1
			end
			debug_print[i] = debug_print[i]..stringspacer("|", 20)
			i = i + 1
			continue
		end
		local v = tostring(v)
		debug_print[i] =  debug_print[i]..stringspacer("| "..k..": "..v, 20)

		i = i + 1
	end

	for k,v in pairs(debug_print) do
		print(v)
	end
	
end


net.Receive("gs_cl_runOnClient", function()
	local ply = net.ReadPlayer()
	local fun = net.ReadString()

	if ply then
		player_manager.RunClass( ply, fun )
	end
end)

net.Receive("gs_cl_init_stat", function()
	local ply = net.ReadPlayer()

	if ply then
		player_manager.RunClass( ply, "InitClientState" )
	end
end)

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
--[[
net.Receive("gs_cl_weapon_drop", function(_, ply)
	local ent = net.ReadEntity()
	player_manager.RunClass( ply, "DropSWEP", ent )
end)
--]]

net.Receive("gs_cl_inventary_examine_item", function(_, ply)
	local from    = net.ReadUInt(5)
	local keyitem = net.ReadUInt(6)
	player_manager.RunClass( ply, "ExamineItemFromInventory", keyitem, from)
end)

--[[
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
--]]
net.Receive("gs_cl_actions_human", function(_, ply)
	local target = net.ReadEntity()
	local act    = net.ReadUInt(3)

	player_manager.RunClass(target, "MakeAction", ply, act)
end)

net.Receive("gs_equipment_update", function(_, ply)
	local key = net.ReadUInt(5)

	player_manager.RunClass(ply, "RemoveEquip", EQUIP_NAMES[key] )
end)

print("SKIBIDI")