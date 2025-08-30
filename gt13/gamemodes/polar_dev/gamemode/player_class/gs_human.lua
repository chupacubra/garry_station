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


local DEBUG_CD = 1
local Next_DebugPrint = 0
local start_y = 500

local w, h = 2560, 1600
local text_size = 15
local start_x = text_size
local start_y = 500

local pos_x = start_x
local pos_y = start_y

local color = Color(255,255,255)
local debug_colors = {
	default = Color(255,255,255),
	table_label = Color(251,222,0),
	bool = {
		["true"] = Color(76,223,43),
		["false"] = Color(83,74,249),
	},
	zero_int = Color(200, 200, 200),
}

local function RecursDebugScreenText(tbl, str_x, str_y)
	local pos_x, pos_y
	for k, v in pairs(tbl) do
		pos_y = start_y + (str_y * text_size)
		pos_x = start_x + (str_x * 20)
		local typ = type(v) 
		if typ == "table" then
			debugoverlay.ScreenText( pos_x / w ,  pos_y / h, tostring(k)..": " .. "#"..tostring(table.Count(v)), DEBUG_CD, debug_colors.table_label )
			_, str_y = RecursDebugScreenText(v, str_x+1, str_y+1)
			str_y = str_y - 1
		elseif typ == "boolean" then
			debugoverlay.ScreenText( pos_x / w ,  pos_y / h, tostring(k)..": "..tostring(v), DEBUG_CD, debug_colors.bool[tostring(v)] )
		elseif v == 0 then
			debugoverlay.ScreenText( pos_x / w ,  pos_y / h, tostring(k)..": "..tostring(v), DEBUG_CD, debug_colors.zero_int )
			
		else
			debugoverlay.ScreenText( pos_x / w ,  pos_y / h, tostring(k)..": "..tostring(v), DEBUG_CD, debug_colors.default )
		end
		str_y = str_y + 1
	end

	return str_x, str_y
end

function PLAYER:BodyDebugPrint()
	
	if !dev:GetBool() then return end
	
	local debug_table = self.Player.Organism_Value // start

	debug_table["HealthStatus"] = self.Player.HealthStatus
	debug_table["Ragdolled"] = self.Ragdolled
	debug_table["CritParalyzeDelay"] = self.CritParalyzeDelay
	debug_table["EffectSpeed"] = self.EffectSpeed
	debug_table["RagdollTime"] = self.RagdollTime

	//self.Player.Body_Parts

	debug_table["Body_Parts"] = self.Player.Body_Parts 
	RecursDebugScreenText(debug_table, 0, 0)
	/*
	    self.Player.Chemicals = CHEMIC_CONTAINER:New_Container(self.Player, 200)
        self.Player.HealthStatus = GS_HS_OK
        self.Ragdolled = false
        self.CritParalyzeDelay = 0
		self.EffectSpeed  = {}
		self.RagdollTime  = 0
	*/
	

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